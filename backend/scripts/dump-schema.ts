import { MikroORM } from '@mikro-orm/postgresql';
import config from '../src/mikro-orm.config';

async function dumpSchema() {
  try {
    const orm = await MikroORM.init({
      ...config,
      connect: false,
    });
    const generator = orm.getSchemaGenerator();
    const sql = await generator.getCreateSchemaSQL();
    console.log('---SQL_START---');
    console.log(sql);
    console.log('---SQL_END---');
    await orm.close();
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
}
dumpSchema();
