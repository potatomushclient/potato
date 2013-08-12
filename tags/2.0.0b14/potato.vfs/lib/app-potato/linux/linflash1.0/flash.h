/*	
		File : flash.h

		Description : Header file for the flash window extension for tk

		Author : Youness El Alaoui ( KaKaRoTo - kakaroto@user.sourceforge.net)

  */

#ifndef _FLASH
#define _FLASH

// Include files, must include windows.h before tk.h and tcl.h before tk.h
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xatom.h>

#include <tcl.h>
#include <tk.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tkPlatDecls.h>

// Defined as described in tcl.tk compiling extension help
#ifndef STATIC_BUILD

#if defined(_MSC_VER)
#   define EXPORT(a,b) __declspec(dllexport) a b
#   define DllEntryPoint DllMain
#else
#   if defined(__BORLANDC__)
#       define EXPORT(a,b) a _export b
#   else
#       define EXPORT(a,b) a b
#   endif
#endif
#endif


#define DLL_BUILD
#define BUILD_Flash

#ifdef BUILD_Flash
#  undef TCL_STORAGE_CLASS
#  define TCL_STORAGE_CLASS DLLEXPORT
#endif

#ifdef __cplusplus
extern "C"
#endif


// Prototype of my functions

EXTERN int Flash_Init _ANSI_ARGS_((Tcl_Interp *interp));


EXTERN int Tk_FlashWindow (ClientData clientData,
			   Tcl_Interp *interp,
			   int objc,
			   Tcl_Obj *CONST objv[]);

EXTERN int Tk_UnFlashWindow (ClientData clientData,
			   Tcl_Interp *interp,
			   int objc,
			   Tcl_Obj *CONST objv[]);

EXTERN int flash_window (Tcl_Interp *interp, Tcl_Obj *CONST objv1, int flash);



# undef TCL_STORAGE_CLASS
# define TCL_STORAGE_CLASS DLLIMPORT
#endif /* _FLASH */
