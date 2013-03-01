/*
  File : flash.cpp
  
  Description :	Contains all functions for the Tk extension of flash windows
  This is an extension for Tk only for windows, it will make the window 
  flash in the taskbar until it gets focus.
  
  MAN :
  
  NAME :
  winflash - Flashes the window taskbar and caption of a toplevel widget

  SYNOPSYS :
  winflash window_name 

  DESCRIPTION :
  This command will make the taskbar of a toplevel window and it's caption flash under linux,
  the window_name argument must be the tk pathname of a toplevel widget (.window for example)
			

  Author : Youness El Alaoui (KaKaRoTo - kakaroto@users.sourceforge.net)
  Sander Hoentjen (Tjikkun)
*/


// Include the header file
#include "flash.h"


/*
  Function : Tk_FlashWindow

  Description :	This is the function that does the whole job, it will flash the window as 
  given in it's argument

  Arguments   :	ClienData clientdata  :	who knows what's that used for :P 
  anways, it's set to NULL and it's not used

  Tcl_Interp *interp    :	This is the interpreter that called this function
  it will be used to get some info about the window used
	
  int objc			  :	This is the number of arguments given to the function
	
  Tcl_Obj *CONST objv[] : This is the array that contains all arguments given to
  the function
	
  Return value : TCL_OK in case everything is ok, or TCL_ERROR in case there is an error
	
  Comments     :  http://standards.freedesktop.org/wm-spec/1.4/ar01s05.html#id2527339

*/
int Tk_FlashWindow (ClientData clientData,
			   Tcl_Interp *interp,
			   int objc,
			   Tcl_Obj *CONST objv[]) {
  

  // We verify the arguments, we must have one arg, not more
  if( objc != 2) {
    Tcl_AppendResult (interp, "Wrong number of args.\nShould be \"linflash window_name\"" , (char *) NULL);
    return TCL_ERROR;
  }
	

  return flash_window(interp, objv[1], 1);
}

int Tk_UnFlashWindow (ClientData clientData,
			   Tcl_Interp *interp,
			   int objc,
			   Tcl_Obj *CONST objv[]) {
  

  // We verify the arguments, we must have one arg, not more
  if( objc != 2) {
    Tcl_AppendResult (interp, "Wrong number of args.\nShould be \"linunflash window_name\"" , (char *) NULL);
    return TCL_ERROR;
  }
	

  return flash_window(interp, objv[1], 0);
}

int flash_window (Tcl_Interp *interp, Tcl_Obj *CONST objv1, int flash) {

  // We declare our variables, we need one for every intermediate token we get,
  // so we can verify if one of the function calls returned NULL
  char * win = NULL;
  Tk_Window tkwin;
  Window window;
  Display * xdisplay;
  Window root, parent, *children;
  unsigned int n;

  unsigned int demandsSuccess = 0;

  // Get the first argument string (object name) and check it 
  win = Tcl_GetStringFromObj(objv1, NULL);

  // We check if the pathname is valid, this means it must beguin with a "." 
  // the strncmp(win, ".", 1) is used to compare the first char of the pathname

  if (strncmp(win,".",1)) {
    Tcl_AppendResult (interp, "Bad window path name : ",
		      Tcl_GetStringFromObj(objv1, NULL) , (char *) NULL);
    return TCL_ERROR;
  }

  // Here we ge the long pathname (tk window name), from the short pathname, using the MainWindow from the interpreter
  tkwin = Tk_NameToWindow(interp, win, Tk_MainWindow(interp));

  // Error check
  if ( tkwin == NULL) return TCL_ERROR;

  // We then get the windowId (the X token) of the window, from it's long pathname
  window = Tk_WindowId(tkwin);

  // Error check
  if ( window == (Window)NULL ) {
    Tcl_AppendResult (interp, "error while processing WindowId : Window probably not viewable", (char *) NULL);
    return TCL_ERROR;
  }

  xdisplay = Tk_Display(tkwin);

  /* We get the window id of the root toplevel window */
  XQueryTree(xdisplay, window, &root, &parent, &children, &n);
  XFree(children);

  //Since under *nix Tk wraps all windows in another one to put a menu bar, we must use the parent window ID which is the top one
  demandsSuccess = demands_attention(xdisplay, root, parent, flash);

  // If we disable flash, we make sure the UrencyHint is really disabled
  // If either the WM doesn't support DEMANDS_ATTENTION or setting it failed, we use the Urgency flag
  if (!demandsSuccess || !flash) {
    setUrgencyHint(xdisplay, parent, flash);
  }
  //We return error to make the title change for really shitty/special WMs that don't support DEMANDS_ATTENTION
  //We can't get a reliable way to determine if Urgency failed so even if it was success we ensure that application will use a fallback
  return (demandsSuccess?TCL_OK:TCL_ERROR);
}

int demands_attention(Display *display, Window root, Window window, int flash) {
  static Atom demandsAttention, wmState, wmSupported;
  Atom type_return;
  Atom *curr_atom = NULL;
  int format_return;
  unsigned long nitems_return;
  unsigned long bytes_after_return;
  unsigned char *prop_return = NULL;
  int hasFlag = 0;

  XEvent e;
  memset(&e, 0, sizeof(e));
  // We need Atom-s created only once, they don't change during runtime
  demandsAttention = XInternAtom(display, "_NET_WM_STATE_DEMANDS_ATTENTION", True);
  wmState = XInternAtom(display, "_NET_WM_STATE", True);
  wmSupported = XInternAtom(display, "_NET_SUPPORTED", True);


  if( XGetWindowProperty( display, root, wmSupported, 0, 4096, False, XA_ATOM,
                            &type_return, &format_return,
                            &nitems_return, &bytes_after_return,
                            &prop_return ) == Success && nitems_return ) {
    for( curr_atom = (Atom *)prop_return; nitems_return > 0; nitems_return--, curr_atom++) {
      if ( *curr_atom == demandsAttention) {
        hasFlag = 1;
        break;
      }
    }
    XFree( prop_return );
  }

  e.xclient.type = ClientMessage;
  e.xclient.message_type = wmState;
  e.xclient.window = window;
  e.xclient.display = display;
  e.xclient.format = 32;
  e.xclient.data.l[0] = flash;
  e.xclient.data.l[1] = demandsAttention;
  e.xclient.data.l[2] = 0l;
  e.xclient.data.l[3] = 0l;
  e.xclient.data.l[4] = 0l;

  /* If the WM doesn't support the DEMANDS_ATTENTION, then we still send the event because some 
   * WMs (like xfce) support it but they tell us they don't. And we return TCL_ERROR just to make sure
   * in case it *really* didn't support it, that the calling application does the fallback action.
   */
  hasFlag = XSendEvent(display, root, False, (SubstructureRedirectMask | SubstructureNotifyMask), &e) && hasFlag;

  return hasFlag;
}

int setUrgencyHint(Display *display, Window window, int flash) {
  XWMHints *hints;

  hints = XGetWMHints(display, window);
  if (hints != NULL) {
    if (flash)
      hints->flags |= XUrgencyHint;
    else
      hints->flags &= ~XUrgencyHint;
    XSetWMHints(display, window, hints);
    XFree(hints);
    return 1;
  }
  return 0;
}


/*
  Function : Flash_Init

  Description :	The Init function that will be called when the extension is loaded to your tk shell

  Arguments   :	Tcl_Interp *interp    :	This is the interpreter from which the load was made and to 
  which we'll add the new command


  Return value : TCL_OK in case everything is ok, or TCL_ERROR in case there is an error (Tk version < 8.3)

  Comments     : hummmm... not much, it's simple :)

*/
int Flash_Init (Tcl_Interp *interp ) {
	
  //Check TK version is 8.0 or higher
  if (Tk_InitStubs(interp, "8.3", 0) == NULL) {
    return TCL_ERROR;
  }


  // Create the new commands 
  Tcl_CreateObjCommand(interp, "linflash", Tk_FlashWindow,
		       (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
  Tcl_CreateObjCommand(interp, "linunflash", Tk_UnFlashWindow,
		       (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
	
  // end
  return TCL_OK;
}
