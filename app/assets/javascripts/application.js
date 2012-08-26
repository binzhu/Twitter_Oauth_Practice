// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require_tree .
        
        function PopupCenter(pageURL, title,w,h) {
        var left = (screen.width/2)-(w/2);
        var top = (screen.height/2)-(h/2);
        var targetWin = window.open (pageURL, title, 'toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=no, resizable=no, copyhistory=no, width='+w+', height='+h+', top='+top+', left='+left);
        }
        
$(document).ready(function(){
    
    //popup window for signout of twitter account
    $('#signout_twitter').click(function(e){
        e.preventDefault();
        //alert("clicked!");
        //alert($(this).attr("href"));
        //window.open($(this).attr("href"), "mywindow","width=600,height=600");
        var pageURL = $(this).attr("href");
        var title = "Signout Twitter";
        var w = 900;
        var h = 400;
        PopupCenter(pageURL, title,w,h);
       
        })
    
    //hide all checkboxes, highlight instead
    $("input[type=checkbox]").hide();
    
    //clicking on the user profile will act as clicking the checkboxes
    $('.user-profile').click(function(){
        //alert("clicked");
        var chkbox = $(this).children("input[type=checkbox]");
        if (chkbox.attr("checked") == "checked"){
            chkbox.prop("checked", false);
            $(this).css("background","");
        }else{
            chkbox.prop("checked", true);
            $(this).css("background","#66CCFF");
        }
        })
    
    //flag for mark all 
    var gToggleCheck = false
    
    //button to mark all users or unmarkall users
    $("#markall").click(function(e){
        e.preventDefault();
        //alert("all marked")
        gToggleCheck = !gToggleCheck

        if(gToggleCheck){
                $("#markall").text("Unmark All");
                $("input[type=checkbox]").each(function(){
                    //alert("get stuff");
                    $(this).prop("checked", true);
                    $(this).parent().css("background","#66CCFF");
                    })                
           }else{
                $("#markall").text("Mark All");
                $("input[type=checkbox]").each(function(){
                    //alert("get stuff");
                    $(this).prop("checked", false);
                    $(this).parent().css("background","");
                    })
           }
           //end if toggle check      
        })//mark all click event over
    
    $('input[type=submit].slow').click(function(e){
        
        $("#waitMsg").text("Processing, please wait");
        $("#waitMsg").show();
        $("#waitMsg").append('<img src="/assets/loading.gif" />')
        })
    
    $('input#search').click(function(e){
        if ($(this).prev().val().length()<1)
        {
            e.preventDefault();
            $(this).parent().next().text("Please input search keyword")
            setTimeout(function(){
                $(this).parent().next().text("")
                },2000)
        }else{
        window.location.href =$(this).parent().attr("action") + $(this).prev().val()
        }
        })
    
})