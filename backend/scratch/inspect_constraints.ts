import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();
async function main() {
  const result = await prisma.$queryRaw`
    SELECT 
        cc.name AS constraint_name,
        cc.definition
    FROM sys.check_constraints cc
    JOIN sys.objects o ON cc.parent_object_id = o.object_id
    WHERE o.name = 'KyThi';
  `;
  console.log(JSON.stringify(result, null, 2));
}
main();
