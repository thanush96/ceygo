import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Inject,
} from '@nestjs/common';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { Cache } from 'cache-manager';
import { Observable, of } from 'rxjs';
import { tap } from 'rxjs/operators';
import { Reflector } from '@nestjs/core';
import { CACHE_TTL_KEY } from '../decorators/cache-ttl.decorator';

@Injectable()
export class SmartCacheInterceptor implements NestInterceptor {
  constructor(
    @Inject(CACHE_MANAGER) private cacheManager: Cache,
    private reflector: Reflector,
  ) {}

  async intercept(context: ExecutionContext, next: CallHandler): Promise<Observable<any>> {
    const request = context.switchToHttp().getRequest();
    const isGetRequest = request.method === 'GET';
    const hasAuth = !!request.headers.authorization;

    // Skip cache for non-GET or private user-specific endpoints
    if (!isGetRequest || (hasAuth && request.url.includes('/me'))) {
      return next.handle();
    }

    const cacheKey = `http_cache:${request.url}`;
    const cachedResponse = await this.cacheManager.get(cacheKey);

    if (cachedResponse) {
      return of(cachedResponse);
    }

    return next.handle().pipe(
      tap(async (response) => {
        const ttl = this.reflector.get<number>(CACHE_TTL_KEY, context.getHandler()) || 600000; // Default 10 min
        await this.cacheManager.set(cacheKey, response, ttl);
      }),
    );
  }
}
