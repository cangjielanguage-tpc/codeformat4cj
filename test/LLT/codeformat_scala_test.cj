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
    let formatScala = FormatScala()
    formatScala.testScalaFormat()
    return 0
}

@Test
class FormatScala {
var scalaFormatTestCode = #"
import scala.util.Random
object UnformattedCode{def main(args:Array[String]):Unit={val r=new Random();val numbers=List.fill(10)(r.nextInt(100));println("Original:"+numbers);val filtered=numbers.filter(_>50).map(_*2).sorted;println("Processed:"+filtered);def sumList(lst:List[Int]):Int=lst match{case Nil=>0;case h::t=>h+sumList(t)};println("Sum:"+sumList(filtered))}}
"#
        
    @TestCase
    func testScalaFormat() {
        let output = codeFormat("scala", scalaFormatTestCode, FormatConfig())
        let filePath: Path = Path("../../../test/LLT/scalaFormatTest.txt")
        let allBytes: Array<Byte> = File.readFrom(filePath)
        let expectedStr = String.fromUtf8(allBytes)
        @Assert(output, expectedStr.replace("\r\n","\n"))
    }
}
