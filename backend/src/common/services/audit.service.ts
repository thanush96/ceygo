import { Injectable, Logger } from '@nestjs/common';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class AuditService {
  private readonly logger = new Logger(AuditService.name);
  private readonly auditLogPath = path.join(process.cwd(), 'logs', 'audit.log');

  constructor() {
    this.ensureLogDirectory();
  }

  private ensureLogDirectory() {
    const dir = path.dirname(this.auditLogPath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  }

  logAction(userId: string, action: string, metadata: any = {}) {
    const logEntry = {
      timestamp: new Date().toISOString(),
      userId,
      action,
      metadata,
    };

    const logLine = JSON.stringify(logEntry) + '\n';
    
    // Log to file for persistence
    fs.appendFile(this.auditLogPath, logLine, (err) => {
      if (err) this.logger.error(`Failed to write to audit log: ${err.message}`);
    });

    // Also log to console for container log aggregation
    this.logger.log(`AUDIT: [${action}] by User ${userId} - ${JSON.stringify(metadata)}`);
  }
}
