import { IsString, IsNumber, IsBoolean, IsOptional, IsEnum, IsDateString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { RuleType, TargetType, ValueType } from '../../revenue/entities/pricing-rule.entity';

export class UpdatePricingRuleDto {
  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  ruleName?: string;

  @ApiProperty({ enum: RuleType, required: false })
  @IsEnum(RuleType)
  @IsOptional()
  ruleType?: RuleType;

  @ApiProperty({ enum: TargetType, required: false })
  @IsEnum(TargetType)
  @IsOptional()
  targetType?: TargetType;

  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  targetValue?: string;

  @ApiProperty({ required: false })
  @IsNumber()
  @IsOptional()
  value?: number;

  @ApiProperty({ enum: ValueType, required: false })
  @IsEnum(ValueType)
  @IsOptional()
  valueType?: ValueType;

  @ApiProperty({ required: false })
  @IsBoolean()
  @IsOptional()
  isActive?: boolean;

  @ApiProperty({ required: false })
  @IsDateString()
  @IsOptional()
  startDate?: string;

  @ApiProperty({ required: false })
  @IsDateString()
  @IsOptional()
  endDate?: string;

  @ApiProperty({ required: false })
  @IsNumber()
  @IsOptional()
  priority?: number;
}
