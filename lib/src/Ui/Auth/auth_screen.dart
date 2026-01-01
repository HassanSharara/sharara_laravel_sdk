
import 'package:flutter/material.dart';
import 'package:sharara_laravel_sdk/sharara_laravel_sdk.dart';
import 'package:sharara_laravel_sdk/src/Ui/Auth/WhatsAppGuard/guard.dart';
import 'package:sharara_laravel_sdk/src/Ui/LIBuilder/li_builder.dart';

class LaravelDefaultAuthScreen extends StatefulWidget {
  const LaravelDefaultAuthScreen({super.key,
   this.onPopShouldTrueInvoked,
  });
  final Function(BuildContext)?onPopShouldTrueInvoked;
  @override
  State<LaravelDefaultAuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<LaravelDefaultAuthScreen> {
  final AuthHandler authHandler = AuthHandler();
  @override
  void dispose() {
    authHandler.dispose(context);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop:false,
      onPopInvokedWithResult:(c,__)async{
        if(c)return;
        if(authHandler.screenAuthType.value!=null){
          if(authHandler.screenAuthType.value==AuthType.forget){
            authHandler.changeAuthScreen(AuthType.login);
            return;
          }
          authHandler.changeAuthScreen();
          return;
        }
       final bool ss =  Navigator.canPop(context);
       if(!ss){
         if(widget.onPopShouldTrueInvoked!=null)widget.onPopShouldTrueInvoked!(context);
         return;
       }
         Navigator.pop(context);
      },
      child: LiBuilder(
        builder: (context,configurations) {
          return Scaffold(
            appBar:AppBar(
              centerTitle:true,
            ),
            body:Center(
              child: ListView(
                padding:const EdgeInsets.all(10),
                children: [
                  if(configurations.appLogo!=null)
                    SizedBox(
                      height:80,
                      width:80,
                      child:configurations.appLogo,
                    ),
                 const SizedBox(height:15,),

                ValueListenableBuilder(
                     valueListenable:authHandler.screenAuthType,
                     builder:(final BuildContext context,final AuthType? authType,_){
                       if(authType==null) {
                         return Column(
                           mainAxisAlignment:MainAxisAlignment.center,
                           crossAxisAlignment:CrossAxisAlignment.center,
                           children: [
                             SizedBox(height:size.height*0.20,),
                             RoyalRoundedButton(
                               color:RoyalColors.secondaryColor.withValues(alpha:0.7),
                               title:
                               LaravelConfigurations.configurations?.getLoginWord == null ? "تسجيل دخول"
                               :LaravelConfigurations.configurations!.getLoginWord!(),
                               onPressed:()=>authHandler.changeAuthScreen(AuthType.login),
                             ),
                             if(LaravelConfigurations.configurations?.registerApiKeyWord!=null)
                               ...[
                                 const SizedBox(height:25,),
                                 RoyalRoundedButton(
                                   title:LaravelConfigurations.configurations?.getRegisterWord == null ?  "انشاء حساب" : LaravelConfigurations.configurations!.getRegisterWord!(),
                                   color:RoyalColors.mainAppColor.withValues(alpha: 0.7),
                                   onPressed:()=>authHandler.changeAuthScreen(AuthType.register),
                                 ),
                               ]
                           ],
                         );
                       }
                       return Column(
                         children: [
                           ... authHandler
                               .currentModels
                               .map(
                                   (model)
                               => Padding(
                                 padding:const EdgeInsets.symmetric(vertical:10),
                                 child:model.controller is PhoneTextEditController?
                                  PhoneTextEditor(
                                    isNumberVerified:()=> model.verified  ,
                                    hideVerification:()=> !authHandler.numberNeedToBeVerified,
                                    model:model as  PhoneAuthModel
                                  ):
                                 RoyalTextFormField(
                                   controller:model.controller,
                                   title:
                                   model.column == "password"
                                   ?
                                   model.name.orBuilder(LaravelConfigurations.configurations?.getPasswordWord):

                                   model.column == "password_confirmation"
                                       ?
                                   model.name.orBuilder(LaravelConfigurations.configurations?.getConfirmPasswordWord):

                                   model.column == "name"
                                       ?
                                   model.name.orBuilder(LaravelConfigurations.configurations?.getNameWord):

                                   model.name,
                                   inputType:model.numeric?TextInputType.phone:null,
                                   isPassword:model.isPassword,
                                 ),
                               )
                           ),
                           const SizedBox(height:15,),
                           if(
                           authType==AuthType.login &&
                             LaravelConfigurations.configurations?.forgetApiKeyWord != null
                           )
                            ...[
                              GestureDetector(
                                onTap:()=>authHandler.changeAuthScreen(AuthType.forget),
                                child: Text(
                                  LaravelConfigurations.configurations?.getForgetWord == null ?
                                  "هل نسيت كلمة السر ؟" :
                                  LaravelConfigurations.configurations!.getForgetWord!()
                                  ,style:TextStyle(
                                    color:RoyalColors.mainAppColor,
                                    fontWeight:FontWeight.bold
                                ),),
                              ),
                                const SizedBox(height:8,),
                                GestureDetector(
                                  onTap:()=>authHandler.changeAuthScreen(AuthType.register),
                                  child: Text(
                                    "انشاء حساب".orBuilder(LaravelConfigurations.configurations?.getRegisterWord)
                                    ,style:const TextStyle(

                                  ),),
                                ),
                            ]
                           else if(authType == AuthType.forget)
                             GestureDetector(
                               onTap:()=>authHandler.changeAuthScreen(AuthType.login),
                               child: Text(
                                 LaravelConfigurations.configurations?.getLoginWord == null ? "تسجيل دخول"
                                     :LaravelConfigurations.configurations!.getLoginWord!()
                       ,style:TextStyle(
                                   color:RoyalColors.mainAppColor,
                                   fontWeight:FontWeight.bold
                               ),),
                             )
                           else if(authType == AuthType.register)
                             ...[
                               const SizedBox(height:8,),
                               GestureDetector(
                                 onTap:()=>authHandler.changeAuthScreen(AuthType.login),
                                 child: Text(
                                   "تسجيل دخول".orBuilder(LaravelConfigurations.configurations?.getLoginWord)
                                   ,style:const TextStyle(

                                 ),),
                               ),
                             ],
                           const SizedBox(height:25,),
              
                           RoyalRoundedButton(
                             title:  LaravelConfigurations.configurations?.getForwardWord == null ? "تقدم"
                                 :LaravelConfigurations.configurations!.getForwardWord!(),
                             onPressed:authHandler.callApi,
                           )
                         ]
                        ,
                       );
                     })
                ],
              ),
            )
          );
        }
      ),
    );
  }
}

class PhoneTextEditor extends StatefulWidget {
  const PhoneTextEditor({super.key,
    required this.model,
    required this.isNumberVerified,
     this.hideVerification,
     this.onVerified,
  });
  final PhoneAuthModel model;
  final bool Function() isNumberVerified;
  final bool Function()? hideVerification;
  final Function()? onVerified;
  @override
  State<PhoneTextEditor> createState() => _PhoneTextEditorState();
}

class _PhoneTextEditorState extends State<PhoneTextEditor> {

  String get phoneNumber => (widget.model.controller as PhoneTextEditController).nText;
  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        RoyalPhoneTextFormField(
            title:
            LaravelConfigurations.configurations?.getPhoneWord == null ? widget.model.name
                :LaravelConfigurations.configurations!.getPhoneWord!()
            , controller:widget.model.controller
        ),

       if(widget.hideVerification==null || !widget.hideVerification!())
       ValueListenableBuilder(
         valueListenable:widget.model.controller,
         child:const SizedBox(),
         builder:(BuildContext context,final t,c){

           if(widget.isNumberVerified()){
             return   Row(
               mainAxisAlignment:MainAxisAlignment.center,
               crossAxisAlignment:CrossAxisAlignment.center,
               children: [
                const Icon(Icons.check_circle,color:RoyalColors.green,),
                 const SizedBox(width:5,),
                 Text( LaravelConfigurations.configurations?.getVerifiedWord == null ? "تم التحقق"
                     :LaravelConfigurations.configurations!.getVerifiedWord!())
               ],
             );
           }
           if(t.text.isEmpty)return c!;
           return Column(
               children:[
                 if(!widget.isNumberVerified())...[

                   const SizedBox(height:5,),
                    Text(LaravelConfigurations.configurations?.getPleaseVerifyWord == null ?"يرجى توثيق رقم الهاتف":
                    LaravelConfigurations.configurations!.getPleaseVerifyWord!()),
                   const SizedBox(height:10,),
                   Row(
                     mainAxisAlignment:MainAxisAlignment.spaceAround,
                     children: [

                       if(LaravelConfigurations.configurations?.activateFBPhoneAuth==true)
                         ElevatedButton(
                           style:ButtonStyle(
                               foregroundColor:WidgetStateProperty.resolveWith((_)=>RoyalColors.red)
                           ),
                           onPressed:(){
                             FunctionHelpers.jumpTo(context,
                              FbPhoneAuthScreen(
                                title: "التحقق من رقم الهاتف".orBuilder(LaravelConfigurations
                                .configurations?.getBySendSmsWord),
                                  verificationSucceedMessage:  "تم التحقق بنجاح".orBuilder(LaravelConfigurations
                                      .configurations?.getSuccessFullVerificationWord),
                                  resendOtp: "اعادة ارسال رمز التحقق".orBuilder(LaravelConfigurations
                                      .configurations?.getResendOtpWord),
                                  pleaseInsertOtp:"يرجى ادخال رمز التحقق"
                                  .orBuilder(LaravelConfigurations.configurations?.getPleaseInsertOtp),
                                  phoneNumber: phoneNumber,
                                  onVerificationSucceed:(v)async{
                                    await Future.delayed(const Duration(milliseconds:500));
                                    if(!mounted)return;
                                    _onPhoneVerificationCallback();
                                  })
                             );
                           },
                           child: Text(LaravelConfigurations.configurations?.getBySendSmsWord==null ? "عبر ارسال رسالة نصية"
                             : LaravelConfigurations.configurations!.getBySendSmsWord!()
                           ),
                         ),


                       if(LaravelConfigurations.configurations?.whatsAppAuthor!=null)
                         ElevatedButton(
                           style:ButtonStyle(
                               foregroundColor:WidgetStateProperty.resolveWith((_)=>RoyalColors.green)
                           ),
                           onPressed:(){

                             FunctionHelpers.jumpTo(context,
                             LaravelWhatsAppGuard(

                                 phoneNumber: phoneNumber,
                                 onAuthenticated:_onPhoneVerificationCallback)
                             );
                             // invalid code code
                             // FunctionHelpers.jumpTo(
                             //     context,
                             //    WhatsAppAuthenticator(
                             //     appAuthor: LaravelConfigurations.configurations!.whatsAppAuthor!,
                             //     toPhoneNumber: phoneNumber,
                             //     onSuccess:_onPhoneVerificationCallback,
                             // )
                             // );
                           },
                           child: Text(
                               LaravelConfigurations.configurations?.getByWhatsAppWord==null ? "عبر الواتساب"
                                   : LaravelConfigurations.configurations!.getByWhatsAppWord!()
                           ),
                         ),

                     ],),
                   const SizedBox(height:10,),
                 ]
           ]);
         },
       )
      ],
    );
  }

  _onPhoneVerificationCallback([final String? token])async{
    if(token != null ) widget.model.otpToken =  token;
    if(widget.onVerified!=null)widget.onVerified!();
    setState(() {
      widget.model.verifiedNumber = phoneNumber;
    });
    FunctionHelpers.toast(
        LaravelConfigurations.configurations?.getVerifiedWord == null ? "تم التحقق" :
        LaravelConfigurations.configurations!.getVerifiedWord!(),status:true);
  }
}
