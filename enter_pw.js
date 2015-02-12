
var list = document.getElementsByTagName("input");
// Find the forms.
var user_form = null;
var passwd_form = document.activeElement; //hrmm.. there goes an option..

for(var i=0 ; i<list.length ; i++){
    if((list[i].name == "user" || list[i].name == "login" ) &&
       list[i].type == "text"){ user_form = list[i]; }
    if({%seekPasswdForm}) {  // Finding can be turned off just in case.
        if(list[i].type == "password") // TODO this might not be fool-proof.
        { passwd_form = list[i]; }
    }
}

if(user_form && {%doAccount}){ user_form.value = "{%account}"; }

if(user_form && passwd_form && {%doPasswd} ) { 
    passwd_form.value = "{%passwd}";
    var e = passwd_form;
    while( e && e.tagName != "FORM" ){ e = e.parentNode; }
    if(!e){ 3535; }
    else { e.submit();
           "true";
         }
} else {
    "false";
}
