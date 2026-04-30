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
    let formatKt = FormatKt()
    formatKt.testKtFormat()
    return 0
}

@Test
class FormatKt {
var ktFormatTestCode = """
sealed class NetworkResult{data class Success<T>(val data:T):NetworkResult()
data class Error(val code:Int,val msg:String):NetworkResult()
object Loading:NetworkResult()}
class ApiManager private constructor(){private val retrofit = Retrofit.Builder().baseUrl("https://api.example.com/").addConverterFactory(GsonConverterFactory.create()).build()
private val apiService = retrofit.create(ApiService::class.java)
companion object{val INSTANCE by lazy(LazyThreadSafetyMode.SYNCHRONIZED) {ApiManager()}}
suspend fun <T> request(call: suspend () -> Response<T>):NetworkResult{return try{val response = call()
if(response.isSuccessful){NetworkResult.Success(response.body()!!)}else{NetworkResult.Error(response.code(),response.message())}}catch (e:IOException){NetworkResult.Error(-1,"网络异常:exception")}catch (e:Exception){NetworkResult.Error(-2,"请求失败:exception")}}
suspend fun getUserInfo(userId:String):NetworkResult{return request { apiService.getUserInfo(userId) }}
suspend fun getArticleList(page:Int,size:Int):NetworkResult{return request { apiService.getArticleList(page,size) }}}
interface ApiService{@GET("user/info")suspend fun getUserInfo(@Query("userId") userId:String):Response<UserInfo>
@GET("article/list")suspend fun getArticleList(@Query("page") page:Int,@Query("size") size:Int):Response<List<Article>>}
data class UserInfo(val id:String,val name:String,val avatar:String,val age:Int)
data class Article(val id:String,val title:String,val content:String,val createTime:String)
fun UserInfo.toUserDisplayModel():UserDisplayModel{return UserDisplayModel(id,name,avatar,age,if(age >= 18)"成年" else "未成年")}
data class UserDisplayModel(val id:String,val name:String,val avatar:String,val age:Int,val ageDesc:String)
fun String.formatTime():String{val sdf = SimpleDateFormat("yyyy-MM-dd HH:mm:ss",Locale.CHINA)
return try{sdf.format(sdf.parse(this))}catch (e:Exception){this}}
suspend fun loadUserAndArticles(userId:String,page:Int,size:Int):Pair<NetworkResult,NetworkResult>{val userResult = ApiManager.INSTANCE.getUserInfo(userId)
val articleResult = ApiManager.INSTANCE.getArticleList(page,size)
return Pair(userResult,articleResult)}
suspend fun bindUserInfoToView(userInfoView:UserInfoView,userId:String){    val str = \"""
    标题
    内容第一行
    内容第二行
\"""
val raw = \"""
第一行
第二行
包含"双引号"和'单引号'
\"""
val s1 = "Hello Kotlin"
val s3 = "名字：$name"
val c2 = '5'              // 数字字符
val c3 = '中'             // 中文
val c4 = '@'              // 符号
val result = ApiManager.INSTANCE.getUserInfo(userId)
when(result){is NetworkResult.Success<UserInfo> -> {val userModel = result.data.toUserDisplayModel()
withContext(Dispatchers.Main){userInfoView.setUserId(userModel.id)
userInfoView.setUserName(userModel.name)
userInfoView.setAvatar(userModel.avatar)
userInfoView.setAgeDesc(userModel.ageDesc)}}
is NetworkResult.Error -> {withContext(Dispatchers.Main){userInfoView.showError(result.msg)}}
NetworkResult.Loading -> {withContext(Dispatchers.Main){userInfoView.showLoading()}}}}
interface UserInfoView{fun setUserId(id:String)
fun setUserName(name:String)
fun setAvatar(avatar:String)
fun setAgeDesc(desc:String)
fun showLoading()
fun showError(msg:String)}
"""
        
    @TestCase
    func testKtFormat() {
        let output = codeFormat("kt", ktFormatTestCode, FormatConfig())
        let filePath: Path = Path("../../../test/LLT/ktFormatTest.txt")
        let allBytes: Array<Byte> = File.readFrom(filePath)
        let expectedStr = String.fromUtf8(allBytes)
        File.writeTo("../../../test/LLT/kt.txt", output.toArray())
        @Assert(output, expectedStr.replace("\r\n","\n"))
    }
}
