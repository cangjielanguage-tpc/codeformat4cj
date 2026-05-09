// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

package codeformat.test

import codeformat.*
import std.fs.*
import std.unittest.*
import std.unittest.testmacro.*

main() {
    let formatSql = FormatSql()
    formatSql.testSqlFormat1()
    formatSql.testSqlFormat2()
    formatSql.testSqlFormat3()
    formatSql.testSqlFormat4()
    return 0
}

@Test
class FormatSql {
var sqlFormatTestCode1 = #"
select username,age,phone,address from user_list where status=1 and type=1 or type = 2  and create_time between '2024-01-01' and '2025-01-01' order by id desc limit 15;
"#

var sqlFormatTestCode2 = #"
insert into product_info(product_name,category_id,price,stock,sale_num,create_time,status) values('无线机械键盘',26,199.90,860,125,'2025-03-18 14:26:30',1),('蓝牙降噪耳机',26,299.00,520,368,'2025-03-20 09:15:22',1),('桌面立式支架',35,49.90,1200,896,'2025-03-22 16:40:18',0);
"#

var sqlFormatTestCode3 = #"
update user_info set nickname='夏日晚风',age=28,phone='13856789012',email='summer@163.com',update_time='2026-05-07 10:30:45' where id=1086 and status=1;
"#

var sqlFormatTestCode4 = #"
delete from order_data where user_id=529 and order_type=2 and create_time<'2026-01-01' and is_delete=0;
"#
        
    @TestCase
    func testSqlFormat1() {
        let output = codeFormat("sql", sqlFormatTestCode1, FormatConfig())
        let filePath: Path = Path("../../../test/LLT/sqlFormatTest1.txt")
        let allBytes: Array<Byte> = File.readFrom(filePath)
        let expectedStr = String.fromUtf8(allBytes)
        @Assert(output, expectedStr.replace("\r\n","\n"))
    }

    @TestCase
    func testSqlFormat2() {
        let output = codeFormat("sql", sqlFormatTestCode2, FormatConfig())
        let filePath: Path = Path("../../../test/LLT/sqlFormatTest2.txt")
        let allBytes: Array<Byte> = File.readFrom(filePath)
        let expectedStr = String.fromUtf8(allBytes)
        @Assert(output, expectedStr.replace("\r\n","\n"))
    }

    @TestCase
    func testSqlFormat3() {
        let output = codeFormat("sql", sqlFormatTestCode3, FormatConfig())
        let filePath: Path = Path("../../../test/LLT/sqlFormatTest3.txt")
        let allBytes: Array<Byte> = File.readFrom(filePath)
        let expectedStr = String.fromUtf8(allBytes)
        @Assert(output, expectedStr.replace("\r\n","\n"))
    }

    @TestCase
    func testSqlFormat4() {
        let output = codeFormat("sql", sqlFormatTestCode4, FormatConfig())
        let filePath: Path = Path("../../../test/LLT/sqlFormatTest4.txt")
        let allBytes: Array<Byte> = File.readFrom(filePath)
        let expectedStr = String.fromUtf8(allBytes)
        @Assert(output, expectedStr.replace("\r\n","\n"))
    }
}
