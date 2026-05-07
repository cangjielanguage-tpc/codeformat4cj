/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

package codeformat.test

import codeformat.*
import std.fs.*
import std.unittest.*
import std.unittest.testmacro.*

main() {
    let formatPhp = FormatPhp()
    formatPhp.testPhpFormat()
    return 0
}

@Test
class FormatPhp {
var phpFormatTestCode = #"
<?php $num1=5;$num2=8;function getMax($n1,$n2){return $n1>$n2?$n1:$n2;}$maxVal=getMax($num1,$num2);echo"最大值是：".$maxVal;$arr=[11,22,33,44];foreach($arr as $item){if($item%2==0)echo $item."是偶数<br>";}?>
"#
        
    @TestCase
    func testPhpFormat() {
        let output = codeFormat("php", phpFormatTestCode, FormatConfig())
        let filePath: Path = Path("../../../test/LLT/phpFormatTest.txt")
        let allBytes: Array<Byte> = File.readFrom(filePath)
        let expectedStr = String.fromUtf8(allBytes)
        @Assert(output, expectedStr.replace("\r\n","\n"))
    }
}
