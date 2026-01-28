import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { Response } from 'express';

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let message = 'Internal server error';
    let code = 'INTERNAL_ERROR';

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const exceptionResponse = exception.getResponse();

      if (typeof exceptionResponse === 'string') {
        message = exceptionResponse;
      } else if (typeof exceptionResponse === 'object') {
        const errorObj = exceptionResponse as any;
        message = errorObj.message || message;
        code = errorObj.code || this.getErrorCode(exception);
      }

      code = this.getErrorCode(exception);
    }

    response.status(status).json({
      success: false,
      error: {
        code,
        message: Array.isArray(message) ? message[0] : message,
        timestamp: new Date().toISOString(),
      },
    });
  }

  private getErrorCode(exception: HttpException): string {
    const status = exception.getStatus();
    const message = exception.message.toLowerCase();

    // Authentication errors
    if (message.includes('otp') && message.includes('expired')) {
      return 'OTP_EXPIRED';
    }
    if (message.includes('otp') && message.includes('invalid')) {
      return 'OTP_INVALID';
    }
    if (message.includes('token') && message.includes('expired')) {
      return 'TOKEN_EXPIRED';
    }
    if (message.includes('token') && message.includes('invalid')) {
      return 'TOKEN_INVALID';
    }
    if (message.includes('unauthorized')) {
      return 'UNAUTHORIZED';
    }

    // Booking errors
    if (message.includes('booking') && message.includes('conflict')) {
      return 'BOOKING_CONFLICT';
    }
    if (message.includes('booking') && message.includes('not found')) {
      return 'BOOKING_NOT_FOUND';
    }
    if (message.includes('vehicle') && message.includes('not available')) {
      return 'VEHICLE_UNAVAILABLE';
    }

    // Payment errors
    if (message.includes('payment') && message.includes('failed')) {
      return 'PAYMENT_FAILED';
    }
    if (message.includes('insufficient') && message.includes('balance')) {
      return 'INSUFFICIENT_BALANCE';
    }
    if (message.includes('payment') && message.includes('already processed')) {
      return 'PAYMENT_ALREADY_PROCESSED';
    }

    // Network errors
    if (message.includes('timeout')) {
      return 'TIMEOUT';
    }
    if (message.includes('network')) {
      return 'NETWORK_ERROR';
    }

    // Default codes by status
    switch (status) {
      case HttpStatus.BAD_REQUEST:
        return 'BAD_REQUEST';
      case HttpStatus.NOT_FOUND:
        return 'NOT_FOUND';
      case HttpStatus.FORBIDDEN:
        return 'FORBIDDEN';
      case HttpStatus.CONFLICT:
        return 'CONFLICT';
      default:
        return 'INTERNAL_ERROR';
    }
  }
}
