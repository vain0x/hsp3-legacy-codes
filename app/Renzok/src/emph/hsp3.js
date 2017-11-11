function emphLang_hsp3()
{
  var lv =
    {
      comment   : 1,
      string    : 2,
      char      : 3,
      symbol    : 15,
      command   : 16,
      macro     : 17,
      userdef   : 18,
      preproc   : 19,
      label     : 20,
      reserved  : 21
    };

  var keywords =
    {
      intSttmList:
        "screen,buffer,bgscr,dialog,gsel,gradf,gcopy,gzoom,gmode,groll,grect,grotate,gsquare,width,picload,bmpsave,color,syscolor,pget,pos,cls,font,sysfont,redraw,palcolor,hsvcolor,palette,celput,celload,celdiv,mes,print,boxf,line,circle,pset,title,objsize,objsel,clrobj,objprm,objmode,objenable,objimage,objskip,button,listbox,chkbox,combox,input,mesbox,axobj,winobj,if,else,on,goto,exgoto,gosub,return,wait,await,end,stop,onexit,onerror,onkey,onclick,oncmd,repeat,foreach,loop,break,continue,dim,sdim,dimtype,dup,dupptr,mref,newmod,delmod,newlab,newcom,delcom,querycom,mcall,comres,comevent,comevarg,comevdisp,sarrayconv,poke,wpoke,lpoke,getstr,cnvstow,memcpy,memset,memexpand,split,strrep,notesel,noteunsel,noteadd,notedel,noteload,notesave,noteget,exist,dirlist,chdir,delete,mkdir,bsave,bload,bcopy,memfile,mouse,getkey,stick,mmload,mmplay,mmstop,sendmsg,exec,randomize,run,chgdisp,mci,chdpm,assert,logmes",

      intFuncList:
        "varptr,vartype,varuse,libptr,callfunc,ginfo,objinfo,dirinfo,sysinfo,noteinfo,gettime,int,str,double,instr,strmid,strlen,getpath,strf,cnvwtos,strtrim,peek,wpeek,lpeek,length,length2,length3,length4,rnd,limit,limitf,sin,cos,tan,atan,abs,absf,sqrt,expf,logf",

      intSysvarList:
        "err,mousex,mousey,mousew,hwnd,hinstance,hdc,looplev,sublev,system,hspstat,hspver,stat,refstr,refdval,cnt,strsize,thismod,iparam,wparam,lparam",

      reserved:
        ""
    }

  emph = new Footy2.Emphasis();
  with (Footy2) {
    with (emph.emph) {
      flags =
        EMPFLAG_NON_CS;
      independence =
        EMP_IND_ASCII_SIGN | EMP_IND_BLANKS;

      var intCmdList =
        ( keywords.intSttmList
        + "," + keywords.intFuncList
        + "," + keywords.intSysvarList
        );
      for (cmd : intCmdList.split(",")) {
        add(cmd, null);
      }
    }
  }
  return emph.toString();
}
