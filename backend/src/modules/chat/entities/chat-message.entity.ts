import { Entity, PrimaryKey, Property, ManyToOne, Rel } from '@mikro-orm/core';
import { IsBoolean, IsNotEmpty, IsString } from 'class-validator';
import { v4 } from 'uuid';
import { User } from '@modules/users/entities/user.entity';

@Entity({ tableName: 'chat_messages' })
export class ChatMessage {
  @PrimaryKey({ type: 'uuid' })
  id: string = v4();

  @ManyToOne(() => User)
  sender!: Rel<User>;

  @ManyToOne(() => User)
  receiver!: Rel<User>;

  @Property({ type: 'text' })
  @IsString()
  @IsNotEmpty()
  message: string;

  @Property({ default: false })
  @IsBoolean()
  isRead: boolean = false;

  @Property({ onCreate: () => new Date() })
  timestamp: Date = new Date();
}
