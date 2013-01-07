# The default skin, 'potato', for Potato MUSH Client

# Check the packages required by the skin are available
if { [catch {package require Tcl 8.5}] || [catch {package require Tk 8.5}] } {
     return "";
   }

# Check Potato is ready to load skins. If not, trying to define one will cause an error.
if { ![namespace exists ::skin] || [namespace exists ::skin::potato] } {
     return "";
   }

# Check to make sure the version of Potato running supports the same skin spec we do
if { ![package vsatisfies "1.5" "$::potato::potato(skinMinVersion)-"] } {
     return "";
   }
# Basic init of the skin
namespace eval ::skin::potato {}
namespace eval ::skin::potato::img {}

set ::skin::potato::skin(init) 0
set ::skin::potato::skin(name) "Potato Default"
set ::skin::potato::skin(version) 1.5

set ::skin::potato::skin(dir) $::potato::path(skins)
set ::skin::potato::skin(preffile) [file join $::skin::potato::skin(dir) skin.prefs]

# Set some skin options to default values
set ::skin::potato::opts(worldbar) 1
set ::skin::potato::opts(spawnbar) 1
set ::skin::potato::opts(statusbar) 1
set ::skin::potato::opts(toolbarLabels) 0

#: proc ::skin::potato::init
#: desc Set up the initial skin; create images, and basic widgets, and pack them all. Set skin(init) to 1 to confirm we've initiated the skin.
#: return nothing
proc ::skin::potato::init {} {
  variable skin;
  variable widgets;
  variable idle;
  variable opts;

  if { $skin(init) } {
       return;
     }

  loadPrefs
  if { $::potato::misc(tileTheme) eq "xpnative" } {
       ::ttk::style configure Toolbutton -padding 3
     }

  image create photo ::skin::potato::img::upload -data {
     R0lGODlhEAAQAOYAANnZ2aCowJCowJCgsJCYsP/////4//D4//Dw/+Dw/+Do
     /9Dg/zBIYGBwgMDY8HCAkICIoKCgsLDA0MDI0NDQ4FBgcKDAsGC4gFCogFCA
     wGCAoNbV03CAoHCgoIDYcLDwsPD/8GDQYECIsHGJoaC40FC4YIDoYKDwoLDw
     wGCo4ECg0CCgYK/AvWCQ0ECAUFC4QHDgUGCw0ECQ4DDAcCCwUFuWj0BQYFBY
     cHCIoDBwwFCY0FDIUECI4DCgcBCoUCBwcF+GxkCI/0CQ0ECwUECocDB48DB4
     wCCIYE+KiZisxjBw0ECA8ECgUDCAcDBgwDBggLO6vdPW2lJ4nzB4cDB4sDBY
     oIiSpNTS0NHU14CWq1FykTBQgFx0iqqwuf//////////////////////////
     ////////////////////////////////////////////////////////////
     /////////////////////////////////////////////////yH5BAEAAAAA
     LAAAAAAQABAAAAfXgACCg4SFggEBAQECAoADgoIEAAAAAAEFBQYHBwgJCgoL
     DAAAAAABBQ0MDAwNCgoLCwwAAAAAAQYHBwgJCgoLCw4MAAAAAAIHBA8PEBES
     ExQOFQAAAAACBwgJCgoLFhcYGRobAAAAAwgEHAQBHR4fICEiIwAAAAMJCgoL
     JCUmJygpKissAAADCgoLCy2ALi8wMTIzNDUAAAMMNjc4OTouOyo8PT4/gACC
     gwBAQUJDREVGR0iEg0lKS0xNSk5PUISDUVI5U1ROVVZXhIRYWVpbXF2EhISE
     g4EAOw==
  }

  image create photo ::skin::potato::img::mail -data {
   R0lGODlhEAAQANUAANnZ2WxaVOTe1Oze3OTWxOTWvNzStNzKpEQ6LOTezPz+
   /Pzy7Pz69Pz25Pzy1PzqzPzuxEQyLLyinLSmnPz67Pzy3Pz23Pz21PzuzLSa
   fKyObDwuJMzCtLSelPz65My6nLymjNTCxLyqnPzq1LyihKyOfOzavOzetEQ6
   NPTq3NzOtJR2bOTOpPTivNTGvLymlKSShKyahEw6NOTe3PTm1FRCPLSadFxG
   POzm3PTmzPzmvP///////////////////yH5BAEAAAAALAAAAAAQABAAAAay
   QIBwSCwaj0RgQDgkFoWCgUAgEBAIhYKhcDggAgnFYsFYLBaNheMBOUQCkklD
   wWBQKBXLBZPRbAILTkewoFA8wIbjowEdIoGFIiQSLRiNEakEMp1QgdSCoZJI
   Qp/SitVKtRCBFMU1WaResAMh9oG0ZIGZQbRoLIAO2qjSyhxOtcDntfBULI1G
   xeF42D63gAT3eIxGkJwu12qdNLeADCFDIBAyBAIhQ8hkESBAOCQWjUdiEAA7
  }


  image create photo ::skin::potato::img::help -data {
     R0lGODlhEAAQAOYAANnZ2evn7XR01IF/yODf5OLh6nR0zs7O/3R07HSDzn99
     xdrX3t/c1+jl8s6//1ZlzrCw/7Cw7JKDzoKBxN7b2ezo9ZKh/7C//7Ch/5KS
     7IiG1NzW0uvr9ZKS/5KD7HRlzlZWzk1azu7q+Ht76mJvzmBgzjhHzhoasPn3
     /XSD7JiY6o2m8WCQ/1CQ8ICg4HF9zx0OsZKSsHRl7ICN6XCo/6DA/9Dg/1CI
     4Ky+0Ozs7Dg4sFZHzoKP6LDI/+Do8ICIwEBYoLDI8EBw0HZ2zxopsOz77LCw
     zjgpsEVFs4Cg8P///9DQ4JCgwICo4GBowFlZi1ZWsOz/7EBOslCI8LDQ/0BQ
     kJCo0Dc9mKyl2DwusbC/zk194PDw/3CIwODo/6DA8CkviuPk6VZWulZlsIis
     5pCw8MDQ4JCg0HCQ0EBAmbCu2D8/spiz6vD//8DI4DBAkNDo/5C48BAwkKiv
     yEtVvICazzBYwA4rioaKuK+m3XJyujMzojg3izcwi3yBsra4zCH5BAEAAAAA
     LAAAAAAQABAAAAfpgACCgwECAwSDg4OCBQYHCAkKC4IMg4INBg4PEBEREhMU
     g4IVBg4PFhcQEBgZCRobghwGDg8ZEBYdGR4IHyAhACIGDg8ZFhkeCCMkJSYn
     JygGBw8eHikIKissLS4vMDEGEiAIMg8gMzQ1NjY1Nzg5OhI6ICA7PDQ9Pj9A
     P0FCQ4BERUZHOkhJNUo/QEtATE1OT1BRRVBSU1RKSj5LVVY1VwBYWVpKWltU
     SkpcVV1eX2AAAGFiY0VkZUpKZmdeNmhpAAAAAGprbEJUbW5vcHFyc4AAgoN0
     dXYuQV9od3iDg4J5ent8fX5/goEAOw==
  }

  image create photo ::skin::potato::img::log -data {
     R0lGODlhEAAQAOYAANnZ2bDA4LDA0LC40KCw0L3F1f///6CowGBwgL3E1JCo
     wMDI0FBogLzE0//4/5CYsFBggDBIYPD4/5CgsIiSnK7B1PDw8KCgsLBwYNjI
     vr3L2dDY0OCQcNB4YL/G3ODY0MCwgNCIcJA4MMCwcPDgkODIcICIgMCnoODg
     0LCoYNDAYLCYUBAQEMfDt7O8z+Dg4LCgUIaEg5CQkFBjduDo8KCgoMC4kODQ
     cJCYoFNmeY2Yo7CQUIiQjlFkd97b1HBwcFBYUAAAAMvIvP//////////////
     ////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     /////////////////////////////////////////////////yH5BAEAAAAA
     LAAAAAAQABAAAAfLgACCg4SFg4ABgoICAwQFgACCgwACgAaCgwcICYAAgoMC
     gAaCgwoLDA2AAIKCAgYGBg4GBg8MEBGDggOABoKDEhMTFIAAgoIVgAaCgxIW
     FxgYGQAAABqDgg4WGxgcHRgAAAAeg4ISHyADIRgiAAAAHoMGEh8jJCUmIicA
     AAAegwYoKSQqKywtAAAAAC4GDgYvMCQqKywxgACCgi4SBi8wJCorLDIzg4Iu
     BjQ1NjcrLDgTEYOCEzk6NQY7LDw9EREAPoODP0BBQoODAIEAOw==
  }

  image create photo ::skin::potato::img::reconnect -data {
     R0lGODlhEAAQAPcAANnZ2arB3aPA6avD5qnB5anA5KjA46e/4qa+4qS94aO8
     4IGQvqi/2vb7/////////v///P/++/n6+/j6+oaXxoKn26i81+zy+/z9/4KX
     yV6e3nyUxKe51Orw+fT6+anbsI/Rmsro36XbtYGft4WNzXWBw5eXr6W20efs
     9dvw3TStNQCSAACTAB6lIg2fDq3S1MDA/5ic8qSyzeXq8/f7+kGzQhaeGVu8
     ZTOsOQCWALzh3d3x/7K785aVrqKvyeLn8LXgukO0R9Hr3u72/1u7Zrfe2tXr
     /7fC8pSTrKGsxt7j7Pz+/47Rl9Ps6Pv6/7HdyUiwWUe0WEWxV7ne6c3n/7fE
     8pOSq6Cpw9rf6vT7/8/q4ufz/t/v+9rt/9Dn/9zs/93r/8bi/b7h+rTC8pGQ
     qZ+mv9Xb5vT6/87q5BCeEhGeExqjH0ezWM/m/7La5VK3a7nf+7PB8o+Op52j
     vNHY5O/4/8Lk3ACVAACUABOfGIrMrYjLpyGkK2K9iL7h/7C/8I2LpZyhuczU
     4er1/73h2waaBwabBwCXAC2pP67Y8rTb/66+74yKpJudtcjP3eTz/6vayzyv
     TZnSszqvSyyoO1S3dKfV6rba/6zY/6u874uJopqcs8XP29vy/8jn9LTf5NTq
     /7zh+7Lc9L3g/6rY/6XX/6m88YqHoZqasrzE4c7f/8ra/8va/8HW/cHV/77U
     /7jQ/bTO+7DL+67M/J+164mHoZqasX+DtIeKuoeJuIiJt4iIt4iItomItouJ
     t3N7rYiIov//////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     /////////////////////yH5BAEAAAAALAAAAAAQABAAAAj/AAEEEDCAQAED
     BxAkULAAIACBAhk0cODAwQMIESRMoFBhIAALFwA6EDiwAYYMGjYAAACAQ4eB
     Hj6ACCFiBIkSJgAAOIFCYAoVK1i0cPECRgwTAADImOGARg0bN3DkyKFjB48e
     AAD4+OEASBAhQ4isWFHEyBEkAAAkUbKESRMnT6BEkTKFShUrAABcwZJFyxYu
     Xbx8ARNGzBgyAACUMXMGTRo1a9i0cfMGThw5AADMoVPHzh08efTs4dPHzx9A
     AAAEEjSIUCFDdw7hQZRI0SJGAAA0cvQIUiRJkyhVsnQJUyZNAABs4tTJ0ydQ
     oUSNUkSqlKlTAACgSqVqFatWrl7BG4olaxatWgAA2LqFK1euXLp27eLVy9cv
     YAACAgA7
  }

  image create photo ::skin::potato::img::close -data {
     R0lGODlhEAAQANUAANnZ2UBQcLCokPDosP/wsPDwsPDgkLCgkKCgkKCYkKCY
     gP/wwP/ooP/okP/gkP/YgP/QcPDAYIBwYP/woP/ggPDQYPDAUNCYIP/YcPDI
     YPC4UMCQEHBgUPCwQMCIEGBQUKCQgPDQcPCoMLCAEFBAQPC4QOCgMEA4MJCI
     gOCoMOCYIKB4IDAoIJCIcPDgoOC4UOCwMNCgIMCYIMCQILCAIJBwICAgEIB4
     cHBwYGBgUFBQQCAQEP///////////////yH5BAEAAAAALAAAAAAQABAAAAat
     QIBwSCwaj4FA4GgMBIYCgUBwDAACAMGAUDAcjsIA8CAcIhJAhVAIAAQOi8Vi
     QSAwGo4HJCIBABALAqEwaTgokIrlIgEAFAsCgdFwUDCVjGbDAQAUi8KE4aBg
     gJWMpuP5AAAgAoHhoGBCGUtHNCIBAKABo0HBhDKWksg0OgEAqEGDggllLCVR
     SrViAQAtV+gFSwFjshmNNqrZAIDWDZfTnVg24E44BAKEQ2JxGAQAOw==
  }

  image create photo ::skin::potato::img::disconnect -data {
     R0lGODlhEAAQAPcAANnZ2arB3aPA6avD5qnB5anA5KjA46e/4qa+4qS94aO8
     4IGQvqi/2vb7/////////v///P/++/n6+/j6+oaXxoKn26i81+zy+/3///j8
     //L5/36WxV+e33yUxKe51Orw+f3+//f6//H4/+v1/+v2/5up0oGLyHWBw5eX
     r6W20efs9fz///b//+v3/+T7/+L1/9Pf/7i9/5ic8qSyzeXq8/v///u4qfa3
     q+r//+fs9+6jluDd6Njx/9bt/7K785aVrqKvyeLn8P7///jb2P80Bv41BO+w
     pPOIcf8gAO97ZtLp/M7q/7fC8pSTrKGsxt7j7Pr+//H2+/WVgP4zB/8vAP8s
     APpFHN24usrq/8jm/7fE8pOSq6Cpw9rf6vT6/+v8//lYMf8pAP8rAOmLfMf0
     /8bj/8Lk/7TC8ZGQqZ+mv9Xb5u77/+nk7PdmR/8vAv07DP81Bfw8FNuko8Dl
     /7zh/7LB8I+Op52jvNHY5On5/+Tb4vtJIv09Dty3vOWQhf4tAdyPibrh/7ff
     /7C+8I2LpZyhuczU4ePz/9rz/97L09rCy8nu/8fi/c29yrve/rXd/7Lb/629
     74yKpJudtcjP3d7x/9br/8/s/8Hi/7ni/7bc/7HY/63Y/6u874uJopqcs8XP
     29rx/9Lr/8zo/8fm/8Hj/7vg/7bd/7Da/6vY/6XX/6m88YqHoZqasrzE4c7f
     /8ja/sXY/cLW/b7U/brS/LfQ/LTO+7DL+67M/J+164mHoZqasX+DtIeKuoeJ
     uIiJt4iIt4iItomItouJt3N7rYiIov//////////////////////////////
     ////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     /////////////////////yH5BAEAAAAALAAAAAAQABAAAAj/AAEEEDCAQAED
     BxAkULAAIACBAhk0cODAwQMIESRMoFBhIAALFxw4cOAAQwYNGjZw6DDQwwcH
     DhyACCFiBIkSJk6gEJhChQMHK1iIaOHiBYwYMlAInEHDQQ0bN3Dk0LGDRw8f
     PwQCCSJkCJEiRo4gSaJkCZMmAp08gRJFyhQqVaxcwZJFyxaBXLp4+aICTBgx
     Y8iUMXMGjcA0atawaePmDZw4cubQqWNH4B08efTs4dPHzx9AgQQNIiSwkKFD
     iBIpWsSokaNHkCJJEjiJUiVLl7CUwZRJ0yZOnTwJ/AQqlKhRpEqZOoUqlapV
     rAS2cvUKVixZs2jVsnULVy5dAnfxEerly5evX8CABRM2jFgxAAEBADs=
  }

  image create photo ::skin::potato::img::open -data {
     R0lGODlhEAAQAOYAANnZ2YCQoICIoICYsGB4kLCokFBokODQoPDwsP/woP/o
     oLCgkPDwoP/YcKCgkKCYgKCQgJCQgJCIcPDooP/YgP/YYMCwkLCggJCIgPDg
     kODIgP/ggNCoUJiNgf/gkMC4kP/QYP/QUP/IUPC4QOCgMHZnSPDYgP/QcPDA
     QPCwMIBoIJeIZvDQgNDAkP/AUPCoMNCIEGBIINDAgOCgINCQENCwcNCQAMCQ
     AMCIELCAEKB4IJBwIJCAYIB4YIBwUHBgUGBYQFBIQEA4MDAwIDAgICAYEBAQ
     ECAQEP//////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     /////////////////////////////////////////////////yH5BAEAAAAA
     LAAAAAAQABAAAAfJgACCg4SFhoUBAgOHhQSDAQAEAIAFgoKAAIKDggYGBQcI
     CAkKC4SCBgYGCwwICQoKDQ4PDxAREoMLEwkKChSAFYKDEgAAAA4TCgoWFgUF
     FxcPDxAQGBIPGQoaBYAbgoMbDQ0cHQ8ZHgUfDRUVFSAhIiMkJQAQJhoFGycV
     ICAiKCMpKisAECwFLQ0gICIuIykvMDEAABgyBRsgIiIoKS8zNCoAAAASCzU2
     NjY3ODk5OjsxAAAAEjw9Pj9AQUJDREVGR4AAgoOEhYSBADs=
  }

  image create photo ::skin::potato::img::right -data {
     R0lGODlhEAAQAIQAAPwCBEya/AQ2rLza/GSm/GSi9IS+/Hy2/HSy/Gym/FSS
     9HSq/Gyu/FSO9ESG7Hyy/FyW9Dx67KzO/Iy2/EyG9Iyy9AAAAAAAAAAAAAAA
     AAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAVHICCOZGme
     6BikZiCwZDC8KFHYxVDQZm4ciERBwSMRBoYFoxBoOIqi3GNRgDgjUABBwp0o
     KNiTYDxuhGGBSvbkgo3W7jjKHwIAIf5oQ3JlYXRlZCBieSBCTVBUb0dJRiBQ
     cm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4LiBBbGwgcmln
     aHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5jb20AOw==
  }

  image create photo ::skin::potato::img::left -data {
     R0lGODlhEAAQAIQAAPwCBFSa/JTC/Hy2/KTO/Iy6/Aw+rHyy/Iy+/HSu/ISu
     /Iyy9IS6/IS+/Gyq9GSe9FSS9EyG7HSq/FyW9EyK9ESC7Aw+tFSS7ER65Dx2
     5Hym7AAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAVIICCOZGme
     KBmkpbCy4kC8bGEHeGCcBzIkBcVCsSsxEI2D4wGJLIokw+EgeUwolefJUr1U
     MBkItGSYEA3oMVmjTqFhUbh87g8BACH+aENyZWF0ZWQgYnkgQk1QVG9HSUYg
     UHJvIHZlcnNpb24gMi41DQqpIERldmVsQ29yIDE5OTcsMTk5OC4gQWxsIHJp
     Z2h0cyByZXNlcnZlZC4NCmh0dHA6Ly93d3cuZGV2ZWxjb3IuY29tADs=
  }

  image create photo ::skin::potato::img::down -data {
     R0lGODlhEAAQAIQAAPwCBHyq9Fyi/FyGzHSq9KTK/ESC7AQ2rFSS9FSO9Dx6
     5EyK9Dx25FSCzFSa/DRy5DyC7DR25Cxm1ESG7Dx67DR67DRqzCRazAQCxAAA
     AAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAALAAAAAAQABAAAAVEICCOZGme
     aIoGQisMKlHMxqEGBZIodionC0av1CAQHIWF4XFoDkWD2QICiRRqJ8lkS6kw
     UxZDxfs8XciqEaacbrvf/hAAIf5oQ3JlYXRlZCBieSBCTVBUb0dJRiBQcm8g
     dmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4LiBBbGwgcmlnaHRz
     IHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5jb20AOw==
  }

  image create photo ::skin::potato::img::globe -data {
    R0lGODlhEAAQAPcAAGVhb3FwfldWclZcesjM3tba6Q0voBA0phE1phI2phQ4
    qRQ1oRQ3oRY6qRU3oRU2oBc6qhc7qhc5oxo5mx1Aqhs8oBw5kR05jiE8jjNQ
    qEVTgWd3rYeXy5WizZCcww42rhE7tRY7qRY9qRg9qxc7oBpAsRpAqxc3khs+
    pxk6mhk6mRk3kRw8nCFItR9CqiJJtyBFqh0/mh08lR49lh06kSZOux8+lSpS
    vitTvi9azyZGpSE9jyM+jytKoC5OqjheyDhbuS9KmDJOoC9JlTVQn0JesVp/
    41p820JboFt81Vl5z2KE4GGC2jhJeX+TzH+Rw5Ol1RxEriBFoyhTxCFAizpi
    zDlhyTliyD1kyjxixEFoz0lu0DVPlE5z1VB0005wwVJzxFp80GCC3F95unKN
    0ml8rk5vuV6B01h5w1ZytFppi3CBpnKBo4SKmDJRjzBGc1t5tWZ9rH2SvaSz
    0l97r2d2kYWYuJOjvVlhbrjAzYuarnGEnLS7xHaGk4ycomJ6f6q0tX6Hhkhh
    W4SJh0tlWoKYio2bjoKSg7fAt52onJOfj7i9tWBwT4mWdYqVeW6CSVVpKF5j
    T3mSKn+WJWBwH217OWJqRaexg4aVKKGxK7G9TnuBQLG7LpegK7O6S6KoR6it
    V42PccLGdoeJWJqbL7u+UM3Mic/KL7m1T7SyWK+tcaSjdLOnM6efV7GhN9PF
    ZZmKK9zJT+nNQquXMrmpU5uFN8qwTrefSqqbaragarSlhLqFJbibbcyDF7OE
    SYxvS5FnOLJoHLlwKMBoGLZcEr1YE31fS7JTGXFnYXBlZP///wAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAACH5BAEAAMoALAAAAAAQABAAAAj6AJUJFJiHQwcP
    axQNXKgMkahFTwoQ8PHnUSOGgDwVsjPGSREdbghBcjSQzydNl0zF+YDAABVB
    lCzpEqiKU6pYidKUULAgAZ5Ib5Ipm4PqlCw9R7S8aEDBxIBfxoDxurPKkB8j
    YrzgiOACRhBhxYj5khMoy5klTLbcgIAiCoBhx4LVStJnD5owXazUGCFBBLJe
    u2BVInOFDhwwOaa0COGAgYZboxhtglLly6tSh4CAOPBgQgouPJrgUqbEjK1O
    mUDVEVKBhYwVJwQMxDLIlaRJrHL1UGHhAoY2C3+EIoVpVgASM2js2MBQGRta
    rdRIiWFjSPOFZTIQQdI8IAA7
  }

  image create photo ::skin::potato::img::events -data {
     R0lGODlhEAAQANUAANnZ2dDIkNDAkNC4kMCwgMCogLCggLCYcKCQcP/w0PDo
     wPDosPDgkPDggPDYcODQcGBIMNDAgLCogLCgYKCQYIBwQMCoYFBIMJCIcIB4
     YGBYQFBAMEA4MKynoNDAcNC4YMCwYK2oopCIUIB4UHBgQK6po///////////
     ////////////////////////////////////////////////////////////
     /////////////////////////////////yH5BAEAAAAALAAAAAAQABAAAAab
     QIBwSCwaj8RAQDAgFAwHBMIoSCQUC0bD8YAYBwlFICAYEAqGAwIxJCgCgkRC
     sWA0HA/IsLCIDIAJRSAgGBAKhgMCIWFMCIqAIJFQLBgNxwNioFQKi8ggoVgw
     Go6H5QIAACSMCUGxYDQcmIxmAwAAAQZKpbBgNByPzIPTAQKEQwnD8wFZNJzQ
     cAgwUEQj0mVTAgKEQ2LReEQmi0EAOw==
  }

  image create photo ::skin::potato::img::find -data {
     R0lGODlhEAAQAJEAANnZ2QAAAP///////yH5BAEAAAAALAAAAAAQABAAAAJT
     hI+JEUFwIswMKAoAhATBh4i4oITwKTacEeyQiACKEgEAQPHhDsBICUSEUGww
     MTgSY4PJnVBsuAu4C4IoIgh2SEQARYkg2CERARSbYFNsgo+pmwUAOw==
  }

  image create photo ::skin::potato::img::pad -data {
     R0lGODlhEAAQAOYAANnZ2Wtra4WFhYCAgHd3d4SEhHV1dZubmz4+PqGhobW1
     ta2trcPDw6+vr66ursDAwFZWVvz8/P///8vLy11dVBcXMAAAprOzs+jo6Obm
     5ufn57+/u1hYTgkJlkND87i4uPDw8O/v7/Hx8MjIxwUFlElJ+FBQy7S0tOrq
     6vPz7mNjsy8vykxM6AAA1u7u8K2tsEREVBoaywAA2vHx8/Hx7GxsSi4uJgMD
     KQAAuwAAZunp6tra38LCeeXlcDY2LwAAAAAAGOjo5+np7d3d3s/PWvz8dczM
     Y3NzFAkJHAICAPHx9Ozs38/PhOLibqqqe19fAElJJFdXY+np6eLi2Z2dWZGR
     U5OTmYiIho2Nh7KytmNjYhYWFuHh4Xp6X29vZsHBy+Tk5fPz9PX198HBwV1d
     Xbm5ufHx8e7u7t7e4fz8/fX19bCwsGFhYWlpaWhoaGdnZ0NDQyUlJf//////
     /////////////////////////////////////////////////yH5BAEAAAAA
     LAAAAAAQABAAAAfrgAAAAQIDBAUDBAUDBgcIggAJCgsMDQsMDQsMDg8QggAP
     ERESERESERESERMUFRYAFxiAGYKDghobHB0eAB8ggCGCg4IiIyQlJgAnKIAY
     goMYGikqKywtACcohIMuLzAxMjIAHyCAIYKDMzQ1Njc4OQAnKIAYgoI6Ozw9
     Pj9AAAAnKINBQkNERUZHSEkAAB8gISEhSktMTU5PUFEAAAAnKIJSU1RVVldY
     WVpbAAAnKBhSXF1eX2BhYmNkWwAAZWYgIGdoaWpmICAMZFsAAGshZ2dnZmdn
     Z2dmD2wAAAAAbW6Ab4KDbwFwcQAAgQA7
  }


  image create photo ::skin::potato::img::searchImg1 -data {
     R0lGODlhKgAaAOYAANnZ2ZqbmIqMiX6AfXV3dHZ4dXR2c3h6d31/fIeJhpSW
     k4iKh5GTkKeppra4tbjAyMTGw8bIxZKUkYSGg42PjKiqp9HX2d3j5efp5uvw
     8+zx9PDy7+Xq7autqubo5fX6/fn7+P7//Pf9//f59uPl4YuNipaYlbO8xO7w
     7fv9+tbb3bK0sZ6gnaCin6Smo9bY1fHz8Pb7/pWXlHJ0cfr8+dPb5KmrqLGz
     r2ZnZVlbWFpcWV1fXF9hXrCyrvj691tdWmhpZ8/RzsnR2uLn6rO1spykrFdZ
     Vqaopaqsqenr6N3f3GBiX25wbXx+e9LU0e3v69vd2ujq5+/19/b49PL3+cvO
     yv//////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     /////////////////////////////////////////////////yH5BAEAAAAA
     LAAAAAAqABoAAAf/gACCg4SFhoeIiYqLjI2CAQIDBASABYKDhIQEBgcICQqA
     AIKDhIUBCwwNDg8QgBGCg4SEEA8ODRITFIAAgoOEghUUAQ8WFxgZgBqCg4SF
     GxkcFxYPARMSgACCg4MdDB0WHhkfICAhgCKCg4SEISAjHxokFh0lJoAAgoOC
     AScWKCAgIiEigCGCg4SEIiEiKYIfGiorJSyAAIKDLS4vMDEpEDIzBgERgCGC
     g4SFISIiKTQaNTYSgACCgwEWGiAhNzg5Ojo7PD2AIYKDhIWFGhYSAQAAAAAu
     Dh4+IRA/QAFBQgFAOxGGhoYpI0NEDAAAAAABQRopIRI5RRmCGS0/DIaG/4Ui
     ISkaQRIAAAAALioggkBGL4Q1RkCGhoYhIjQqAQAAAABHHimCQEYqhBdGOIaG
     hiEiMRyAAIKCSBw0ISECRj0hISEhSEYlgCGCg4SFhSlJgACCgxw0ISEPRkAr
     Qxg9QDkngCGCg4SFhTQYgACCg0oxISEhRT87Szs4OkYFgCGCg4SFhTEXgACC
     gwA+ISEhISsJODgTRUw6TYAhgoOEhYQjToAAgoMAGSKAIYKDF4NAP02Dg4OD
     g4I0T4AAgoOCUD6AIYKDhBdAS0GEhISDIh9QgACCg4McH4AhgoOEKg+EhISE
     KRiAAIKDhAAcIIAhgoOEhYaEIiBRgACCg4SDF01SKYAhgoODIoSEhCkjF4AA
     goOEhQAXKFM0ISEhISKAIYKDhCE0VBkXVYAAgoOEhYYWFhYWLy+AFoKDhBYR
     gACCg4SFhoeIiYqLjI2EgQA7
  }

  image create photo ::skin::potato::img::searchImg2 -data {
     R0lGODlhKgAaAPcAANnZ2a+7yKO7zJ660Z250Jy4z5mwwbS9xaG4ypa20o+0
     1pOzz42y1IerzY2pv5GoupuntJykrJW10Y+uy4enw4GhvX+asHqVq3yXrX2c
     uIKivoaqzIunvZCnuZmlsrjD0aS/1oioxH6euZSsvaizway4xbO/za7CzoSf
     toSkwIysyKC3yYahuMLL09bb3ebo5e7w7e/x7vDy7+zx9Ovu6omlu4eiuZqu
     ud3j5evw8/L3+fb7/vv9+v7//PX6/enu8ODp8YOetYWlwZCrwqS8zZS00Iij
     usnR2unr6Pj69/f9//n7+NPb5J6yvompxZWtvsHN28TGw5WXlHJ0cXR2c5qb
     mMbIxfb49JCvzLW+xqK5y42tyrvP2+Xq7bGzr2ZnZVlbWFpcWV1fXF9hXrCy
     ruHq8rnE0ourx/P18ltdWmhpZ8/RzpqxwpyotbC8ypKUkaCin5GTkKnB05q1
     zI6z1VdZVtbY1aC805SvxsTY5Pr8+YqMiaqsqYuNipKtxJ+70paxyMvX5bjA
     yLK0seLn6ufp5rO8xI6qwYiszqW9zu/192BiX3Z4dYeJhoSGg25wbXx+e5m0
     y83Z54qqxq/G2Nzo9sDU4Z6qt9Le7OPs9LXBz9Xh79nl9MrW5LLK25KxzpOu
     xabB2Yyx05Gsw5eqtv//////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     /////////////////////yH5BAEAAAAALAAAAAAqABoAAAj/AAEIHDgwgIAB
     BAgUKECgQIECAwgQKFCAAMACAgUaAAhA4ECCBQEcCIAggYIFABkIHEiwIMEG
     Dh5AiAAQgMCBBAEEQCBhAoUKFgBeEDiQYMGBGDJo2MChgweAAAQOHPgBxIIQ
     IjyMIFEiAEATAgeaAHhC4ECBJUiMQCEihQoDAAEIHCgwwAoVLDqsaOHiBYwY
     AGUIHAgwhsCBMGDMoPHCRQsSNTLYeAABIACBAk0McGDjRgscOXTs4AGwh8CB
     BAsK9OHjB5AWN4IIGQIQgECBRIoYIXEESZIePZQA7CFwIMGCBZfsyMGkCQon
     IwAAAPBhwIYnUGYo6RFFyhQqVawY/zRosMcVGkeeCMECAEAWLVsocOmypIeX
     L2DChBEzhoxBgwZ3LCljxkiIBwACJDhjgAmaHlHSqKmy5kgVNWKsGDRosMcV
     JmyEnGnjZkGIEz8EvgETIYfAHHDSxDFo0OAOJT/kGGkwYg4dDlB8CFRTxw5B
     JnXUGDRoUKCPFhQaDJnDwMGRHTt6qKnjgiCOOl8MGjTYg8cOJg42OLhDB08e
     PQL31CFDkE+dPgYNGuyhhEcePxv8/FEAKJAPJT0E1VEziFAhMmrAGDJo0KDA
     JXkOIRqSKAEWLooGRkgjZpGYL2HqMDJo0KBARVAmTHgSYA4iOUB87BA4qNGX
     L44ARngUBv8SwB4CBxIsOHAHEDlO/AD4QKRIJEk6DOIYqCYNJIMGC+qQBGjS
     CAAAPiSgQwnIDoMDcahZtMagwYE7KlFSMQEAAAAHSACaY2nGDoMDXQgyaHDg
     jhmWAE16AAAAAAAn7hT5Y6mMDiUGDRokqERHGUsEzlwCCEDgwCwCIhGghCmT
     DiUAewgc2EMJQYIClejIhIlSJBUjRgAEIHAgAE0CEii4QynQJk4AKwkcSLBg
     JSCbOnlK8AkUHoAABA4kGGDAnE8KEtxJBBCEQIGhBg4cKLBAEUQqJjmIABCA
     wIEEBZpIlCABQAUCBxJUAFCUwIEbGohSMWoEKYAABA4kWPDAiQEbfwYMIECA
     AAICBAgQGDVqlAMHQ4aMcjCiYMGAADs=
  }


  image create photo ::skin::potato::img::searchGlass -data {
     R0lGODlhDQANANUAANnZ2cbIxZqbmHR2c3J0cZWXlMTGw7Cyrl9hXl1fXFpc
     WVlbWGZnZbGzr2hpZ8nR2s/RzltdWpGTkKCin+vw85ykrJKUkVdZVtPb5NbY
     1d3j5dbb3YuNiqqsqYqMibO8xOfp5uLn6rK0sbjAyHZ4dWBiX3x+e25wbYSG
     g4eJhv//////////////////////////////////////////////////////
     /////////////////////////////////yH5BAEAAAAALAAAAAANAA0AAAZ5
     QIBQGBAMCAXDcHhAJBSKBaMxBAQSDsEDInBEDENJZEIRUioLy9BxwQwBmYtj
     yLhohoDNxTHkXIAdAAAAOFw8AADgs3AcQCGR4zICAACki4KRKCUiFQAAYFKc
     KigGIyUCAACmiAMAAGiAAKEQUnJohsMhYLQZDoeAIAA7
  }

  image create photo ::skin::potato::img::worldNewact -data {
     R0lGODlhFAAUAOYAANnZ2WKU3m6a342w44Co4WSS20N80jl00yxryAlAjZ+y
     zpWqxpOmxoKZvXKOuWB9qD9fjEBXebzR79rn/t/q/tPj/MnY9rzL4pOkuj1R
     brfN77TI6a/D35SsyoGTrnWFm2JwiDlJZWuFr2mEqlVtk0BRcDhHYDFFX112
     n1FojD5LZC5CV1dukzhLZrbM73eRssvb9Nbj9dfl/XqTt8XY89bh89Tf9s/f
     +sbW82R+o67I8Nfj9tTd9s/d98bY87bG5ZClwkBYfMHS8Nbj+ubs+8XT6bTD
     2qKxxoGNpT9RbJa67W6f5XGZ11J8uUJppDxfkjBOgDVGYThqszRosjNjoyVR
     kRlDggQubwcsYwQqXQEiVf//////////////////////////////////////
     ////////////////////////////////////////////////////////////
     /////////////////////////////////////////////////yH5BAEAAAAA
     LAAAAAAUABQAAAeNgACCg4SFhoeIiYqJAQIDBAUGBwgJiwAKCwwNDg8QEYsA
     EhMUFRYXGBmLABobHB0eHyAhi4IiIyQlJieLhCgpKiuLhiwti4cuL4uGMDEy
     M4uENDU2Nzg5i4I6Ozw9Pj9AQYsAQkNERUZHSEmLAEpLTE1OT1BRi1JTVFVW
     V1hZWoAAgoOEhYaHiImKiwCBADs=
  }

  image create photo ::skin::potato::img::worldbarDc -data {
     R0lGODlhFAAUAPcAANnZ2ac/PZ4yL7lhY6ElJZcAAJkEAp0IBZoHBKIdG71Y
     XLBJR48AAJ0AAZ8MCaAPC6MSDqQUEZ8LCq0wLrRQUJkAAKIHCJ8PDp8SEKET
     E6QWFqUZGKQbG6ggHqcVGqs3P5gCAqELCJ0RD58TEKMVFaMYGaYbHKcfH6ci
     IqkkJK0nKaodI9GRi75TWJYFAJ4VDqMWFKMZGaIeGqcgHasgIqohIqckIaoo
     J68tLa8uLLtQUaMlJ6MPDaMXGKMfHqocHacVFZYNC40HB4oDA4wDApIDA5wH
     BqEUEbQuK6IWEqQYF6keII0FBYIAAIAAAIUAAI0AAJ4AAJ8AAKIAAKEAAKci
     IJwODoEAAH8AAIYAAJAAAJoAAKgAAK4AAK0AAKwCAsBbXJMFB4QAAIMAAIkA
     AKQAALUAALwAAMAAAMcfGnsAAJMAAKAAAKwAALgAAMgAAMkAANdxZak/PXgA
     AIoAAJYAAKMAALQAAL0AAMoAANQAANYYFZsrK4wAAJgAALYAAMMAANAAANIU
     D7FdW4UHCKUAALsDA9I9NsBnYasuK7MpIMtVTP//////////////////////
     ////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     /////////////////////yH5BAEAAAAALAAAAAAUABQAAAjgAAEIHEiwoMGD
     CBMSDCBAYcEBBAoYOIAggQKFABYwaODgAYQIESRMSEihgoULGDJo2MChg4cP
     CEGEEDGCRAkTJ1CkULGChcEWLl7AiCFjBo0aNm7gyKHD4A4ePXz8ABJEyBAi
     RYwcQWIwiZIlMJg0cfIESoEoUqZQMVhlhpUrWK5k0bKFCpcuXr4YBBMGSxMx
     Y8gUKNPFzBk0aQ6qGdNkTJY1bNq4QfMGTpyDcuaMGUOnjp07ePLo2ZOQzxwx
     ffyU+QMokCCFAAYRGlOnUBdDhxQSRJRI0SKFChUqVKgQYUAAOw==
  }

  image create photo ::skin::potato::img::worldbarUp -data {
     R0lGODlhFAAUAPcAANnZ2cbw+MDu+KDi94TY+X3X+YnZ/KXl/Mjy/cvz/Y3d
     +1e+9Uy28k6w8EWs9zOp9jOp81LA+Jbh/M7u+nXR+FO4+G6391+v90en9kSj
     9UCj+j6g9zKe9Dmr8n7W+HzU+li4+Gm190Cg8DOe+TWg/Tui+kCk+kKm+kWk
     /EWj/T6q+Ibc+qjl/E+59l6x9TKf+TWg/Dqi+z2j+UCk+0Om+0Wo+keq9k2p
     9Uin+ky8+q3q/XjQ+Eaw9UCh9zii+j6k+EOj9kal9kqp+k+s+1Cr+VGt+VKu
     +lqt+Uuu+X7Y+sjx/Fq++T2l9D6h+UOk+kWn+Uar90Cm9jaf+i2a9yqa9zCg
     9z2o+Euz+1m2+G3O+8Dr+ki1+Tqg9kSl+kir+Dyj+B2S9gmH9gCC9gOJ+A6X
     /Bqg/SSo+yqr+DOu+1TI/cbr/b7u/0W4+0Kk90ip9SKZ9waE9ACF9wCH+QWN
     +Rud+i6r+jq0+ES4+0m6/EO5+VrI+Mjr/Mfw/1jB+Tuo+B6R7gCE+QGE+gGE
     +AWJ8xWc+yys/kG3/VC/+2HB/GrG+mHG+W7S/3/T+g+T8gCE9wOH9wKF9wGF
     9Q2R+CSm/zy1/VW/+2rH+nvL+YfT9nzQ+4fb/K/q+yun9QCA+AOH8wKH9hWY
     /TCt/0m7+2XF+H/P95fY9aPj9n3X9bHl/YXb/RSW9ACA9QCF+wSK9hye+DSx
     /VG/+nDH94vW87Tj9pvh94/f+X7W+R2g9gCC9Bqc+DC0/lO//XPG+43T/ZDY
     +Ivd9prl/FW/9iOj8x+l+DKz/Em/+2XL/HjW9pvj+M7y+6nq/ZDg/Y/b/pje
     +6jm/czu/v//////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     /////////////////////yH5BAEAAAAALAAAAAAUABQAAAj/AAEIHEiwoMGD
     AgMgRChgAIECBg4gQDgwgYIFDBo4eAAhggSEACZQqGDhAoYMGjZw6OAB4QcQ
     IUSMIFHCxAkUKVSsMMiihYsXMGLImEGjho0bOHLoKLiDRw8fP4AEETKESBEj
     R5AkIahkCZMmTp5AiSJlCpUqVq5gyUJQyxYuXbx8ARNGzBgyZcycQZNGzcA1
     bNq4eQMnjpw5dOrYuYMnj549A/n08fMHUCBBgwgVMnQIUSJFiwoyauToEaRI
     kiZRqmTpEqZMmgpu4tTJU6RPoEKJGkWqlKlTqAymUrWKVStXr2DFkjWLVi2E
     tm7hipRL1y5evXz9QigQWDBhw4gVFjN2DBlCgsmULWPWzNkzhAgRIkRoMCAA
     Ow==
  }

  image create photo ::skin::potato::img::worldbarNewact -data {
     R0lGODlhFAAUAPcAANnZ2fbKcPbUlvPcpPLBfu22cO6xbOymW+qjSOisUvDO
     jfbMke+6feuva+akUeuhT+qjUuujVemiVOqfTe21afXRjvG1e+6iTuqdROui
     TuujVOulV+unWe+mW+mkU+u/cvK1c+ukUeqgTuuiUuuiVeymUOumWOuoXOup
     X+uqYu6rWuqnX/HcrPXMi+ylWuyfS+ujU+qkV+mqXe2qXeupXu2qXu+oXOus
     Y+yvau6vaPHDfe6xYOygUeuoWuqkT+iYPuiQLOaNJOmPIuuXHeqeJ+ulOPO3
     VO2mSOylWOyqXOykTOOSL+OFIeODG+aHGOqPFu6YFPGcEO+eDuuhB+2mF+yv
     VOepYeuYQuSGHeSFFuaEGuaJGOiSFuubEu6lDfSpDvauCPaxBvSzEvXHhOqR
     NuaEF+SGF+aHG+KGG+ePGO2aFvKkE/OtDfa3Cfm7EPm9AvXJMeWDFOeBHOOG
     G+WGHOSIGuuTFO2gD/KtDPW2B/3ABf7HBv7LAPrgb/CvWuKABOWDG+eFG+aM
     HeyWFfKkDPSyCfm+B/vLCPzYAPbjJe6jRuJ9DeaDGOeOG+qaFPGnDva1C/rB
     AvrOAPrmH/O8a+GPJeaHD+2UDvOlDPqvAPnECvraSPXId+69R+/CQvnVY///
     ////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////
     /////////////////////yH5BAEAAAAALAAAAAAUABQAAAjgAAEIHEiwoMGD
     CBMSDCBAYcEBBAoYOIAggQKFABYwaODgAYQIEiZQSFjBwgUMGTRo2MChg4cP
     CEGEEDGCRAkTJ1CkULGChcEWLl7AiCFjBo0aNm7gyKHD4A4eMHqc8PEDSBAh
     Q4gUMWLwCJIkSpYwaeLkCZQoUqZQMVjFyhUsWbRs4dLFyxcwYcQYHEOmjJkz
     aNKoWcOmjZs3cA7GkTOHTh07d/Dk0bOHT5+Dfv4ACiRoEKFChg4hSpRQ0SJG
     jRw9ghRJ0iSFAChVsnQJUyZNmxQS5NTJ0yeFChUqVKgQYUAAOw==
  }

  image create photo ::skin::potato::img::worldbarNormal \
     -height [image height ::skin::potato::img::worldbarNewact] \
     -width 1

  image create photo ::skin::potato::img::spawnbarUp -data {
     R0lGODlhDwAUANUAANnZ2ZXgk4naiInSgoPUfXHRbnGlc3i8c3PEbGO/XWeoa
     Xu6e2OzXlWyVU+fU3KlglKiWk6jUz6WQ2uneHy6fnS3c26vdCqLNBuCKA18G2
     qXc2CsYlusWjaZN02hVUGdRwR+AgOBAzGFOh+cHwmOBAiKBQqJCgyJCg2DDV2
     sYAauAwysCQymCQKiAF6gYli9U0TeKDzbJza3LYHQZ3bbU5y7mP//////////
     /////////////////////////////yH5BAEAAAAALAAAAAAPABQAAAZNQIBwS
     Cwaj8ikcslEBgTMAaFgUB4QCYVywWg4jA8iJCIpTigVi/CCyWiMG07H8wGFRM
     gRqWQ6oZIpKissLS5KLzAxMkwzNDVNkJGSSUEAOw==
  }

  image create photo ::skin::potato::img::spawnbarNormal \
     -height [image height ::skin::potato::img::worldbarNewact] \
     -width 1

  image create photo ::skin::potato::img::ssl -data {
     R0lGODlhDAAMAOYAANnZ2S4uMGpqbGprbDAwMmlrcNba37O1ubK1uW5wdCssL
     8rR2C0vMisrLsrR2S4wM2BlbYSKlHqBi2tweGNqaH6EhGVsbXuAfg8NAG1eAO
     /RDu3PFde5ANm7ANi6AObJD/XWFHFhABIPAB4aAJp+AP/RAP/HAP/LAP/TAP/
     KAP/IAP/PAJ2BACAbAB4XAJp0AP+/AP/EAK6JAqmGAp12ACAYAB4WAJlwAv/C
     A/66A//BA5FkCYleCJxyAiAXAB4UAplpB/+6CP2zCP+1B9yXDdeTDf+2B5trB
     yAVAh0SA5hkDf+6EP+zD/+2D5tmDR8TAzEeBn9ODnlKDX9NDjQgBv////////
     /////////////////////////////////////////////////////////////
     /////////////////////////////     ///////////////////////////
     //////////////////////////////////////////////yH5BAEAAAAALAAA
     AAAMAAwAAAd2gACCAAECAwSDiQUGBwgGCYkACgsMgg0OD4kQEYkSE4kUFYkWF
     4IYGRobHB0dHh8gISIjJCUmJygoKSorLC0uLyYwMTIzMTAmNDU2Nzg5Ojs8zT
     o9Pj9AQUJDREVGQkFHSElKS0xMTU3lS05PAFBRUvDxU1QAgQA7
  }


  set widgets(main) [::ttk::frame .skin_potato]
  set widgets(toolbar) [::ttk::frame $widgets(main).toolbar]
  set widgets(worldbar) [::ttk::frame $widgets(main).worldbar]
  set widgets(spawnbar) [::ttk::frame $widgets(main).spawnbar]
  set widgets(pane) [panedwindow $widgets(main).pane -opaqueresize false -showhandle false -orient vertical -borderwidth 0]
  set widgets(pane,top) [frame $widgets(pane).top]
  set widgets(pane,btm) [::ttk::frame $widgets(pane).btm]
  set widgets(pane,btm,pane) [panedwindow $widgets(pane,btm).inpane -opaqueresize false -showhandle false -orient vertical]
  set widgets(pane,btm,pane,top) [::ttk::frame $widgets(pane,btm,pane).top]
  set widgets(pane,btm,pane,top,sb) [::ttk::scrollbar $widgets(pane,btm,pane,top).sb -orient vertical]
  set widgets(pane,btm,pane,btm) [::ttk::frame $widgets(pane,btm,pane).btm]
  set widgets(pane,btm,pane,btm,sb) [::ttk::scrollbar $widgets(pane,btm,pane,btm).sb -orient vertical]
  set widgets(pane,btm,idle) [listbox $widgets(pane,btm).idle -listvariable ::skin::potato::idle(list) \
                -height 2 -width 15 -takefocus 0]
  set widgets(statusbar) [::ttk::frame $widgets(main).statusbar]

  pack $widgets(toolbar) -in $widgets(main) -side top -expand 0 -fill x -anchor nw -padx 6
  pack $widgets(worldbar) -in $widgets(main) -side top -expand 0 -fill x -anchor nw
  pack $widgets(spawnbar) -in $widgets(main) -side top -expand 0 -fill x -anchor nw
  pack $widgets(pane) -in $widgets(main) -side top -expand 1 -fill both -anchor nw

  set widgets(togglemenu) [menu .skin_potato.toggleMenu -tearoff 0]
  set widgets(rightclickOutputMenu) [menu .skin_potato.rightclickOutputMenu -tearoff 0]
  set widgets(worldbarRightclickMenu) [menu .skin_potato.worldbarRightClick -tearoff 0]

  if { [info exists opts(inputheights)] } {
       set btmOptions [list -height $opts(inputheights)]
     } else {
       set btmOptions [list]
     }

  $widgets(pane) add $widgets(pane,top) -stretch always -minsize 100
  $widgets(pane) add $widgets(pane,btm) -stretch never {*}$btmOptions
  pack $widgets(pane,btm,pane) -in $widgets(pane,btm) -side left -expand 1 -fill both -anchor sw
  pack $widgets(pane,btm,idle) -in $widgets(pane,btm) -side right -expand 0 -fill y -anchor se
  set topInputPaneOpts [list -stretch always -minsize 20];#jobrand
  if { [info exists opts(input1height)] } {
       lappend topInputPaneOpts -height $opts(input1height)
     }
  set btmInputPaneOpts [list -stretch never -minsize 20]
  if { [info exists opts(input2height)] } {
       lappend btmInputPaneOpts -height $opts(input2height)
     }
  $widgets(pane,btm,pane) add $widgets(pane,btm,pane,top) {*}$topInputPaneOpts
  $widgets(pane,btm,pane) add $widgets(pane,btm,pane,btm) {*}$btmInputPaneOpts
  pack $widgets(pane,btm,pane,top,sb) -in $widgets(pane,btm,pane,top) -side right -fill y -anchor ne
  pack $widgets(pane,btm,pane,btm,sb) -in $widgets(pane,btm,pane,btm) -side right -fill y -anchor ne

  bind $widgets(pane,btm,idle) <<ListboxSelect>> [list ::skin::potato::idleClick]
  set idle(ids) [list]
  set idle(list) [list]

  # Set up the toolbar
  set widgets(toolbar,connect) [toolbarButton 1 connectMenu "" open]
  $widgets(toolbar,connect) configure -command [list ::skin::potato::connectMenu]
  set widgets(toolbar,reconnect) [toolbarButton 1 reconnect "" reconnect]
  set widgets(toolbar,disconnect) [toolbarButton 1 disconnect "" disconnect]
  set widgets(toolbar,close) [toolbarButton 1 close [::potato::T "Close"] close]
  foreach x [list connect reconnect disconnect close] {
     pack $widgets(toolbar,$x) -in $widgets(toolbar) -side left -padx 0 -pady 4 -anchor w
  }

  pack [::ttk::separator $widgets(toolbar).spacer_1 -orient vertical] -side left -padx 7 -pady 5 -fill y
  set widgets(toolbar,prev) [toolbarButton 1 prevConn [::potato::T "Prev"] left]
  set widgets(toolbar,toggle) [toolbarButton 0 [list [::potato::T "Go to Connection"] ::skin::potato::toggleMenu] \
                              [::potato::T "Go To"] down] ;# must be on a newline for translation-tagging script to detect second [T ...]
  set widgets(toolbar,next) [toolbarButton 1 nextConn [::potato::T "Next"] right]
  foreach x [list prev toggle next] {
     pack $widgets(toolbar,$x) -in $widgets(toolbar) -side left -padx 0 -pady 4 -anchor w
  }

  pack [::ttk::separator $widgets(toolbar).spacer_2 -orient vertical] -side left -padx 7 -pady 5 -fill y
  set widgets(toolbar,config) [toolbarButton 1 config [::potato::T "Conf"] globe]
  set widgets(toolbar,events) [toolbarButton 1 events [::potato::T "Events"] events]
  foreach x [list config events] {
     pack $widgets(toolbar,$x) -in $widgets(toolbar) -side left -padx 0 -pady 4 -anchor w
  }

  pack [::ttk::separator $widgets(toolbar).spacer_3 -orient vertical] -side left -padx 7 -pady 5 -fill y
  set widgets(toolbar,log) [toolbarButton 1 log [::potato::T "Log"] log]
  set widgets(toolbar,upload) [toolbarButton 1 upload [::potato::T "Upload"] upload]
  set widgets(toolbar,textEditor) [toolbarButton 1 textEd [::potato::T "Editor"] pad]
  set widgets(toolbar,mailWindow) [toolbarButton 1 mailWindow [::potato::T "Mail Window"] mail]
  foreach x [list log upload textEditor mailWindow] {
     pack $widgets(toolbar,$x) -in $widgets(toolbar) -side left -padx 0 -pady 4 -anchor w
  }

  pack [::ttk::separator $widgets(toolbar).spacer_4 -orient vertical] -side left -padx 7 -pady 5 -fill y
  set widgets(toolbar,find) [toolbarButton 1 find [::potato::T "Find"] find]
  foreach x [list find] {
     pack $widgets(toolbar,$x) -in $widgets(toolbar) -side left -padx 0 -pady 4 -anchor w
  }

  pack [::ttk::separator $widgets(toolbar).spacer_5 -orient vertical] -side left -padx 7 -pady 5 -fill y
  set widgets(toolbar,help) [toolbarButton 1 help [::potato::T "Help"] help]
  foreach x [list help] {
     pack $widgets(toolbar,$x) -in $widgets(toolbar) -side left -padx 0 -pady 4 -anchor w
  }

  pack [::ttk::frame [set widgets(toolbar,searchfield) $widgets(toolbar).searchFrameHolder]] \
               -side right -anchor e -pady 2 -padx 10 -expand 0 -fill none
  if { $::potato::misc(tileTheme) eq "aqua" } {
       ttk::style element create Searchfield image \
                [list ::skin::potato::img::searchImg1 focus ::skin::potato::img::searchImg2] \
                -border {22 4 14} -sticky ew
       ttk::style layout Searchfield "Searchfield -sticky nsew -border 1 -children \
                                  {Entry.padding -sticky nswe -children \
                                   {Entry.textarea -sticky nsew}}"
       set widgets(toolbar,searchfield,e) [::ttk::entry $widgets(toolbar,searchfield).e \
                   -style Searchfield -textvariable ::skin::potato::searchStr]
       pack $widgets(toolbar,searchfield,e) -side right -padx 5 -pady 4 -anchor e
       bind $widgets(toolbar,searchfield,e) <Return> "::potato::findIn {} \$::skin::potato::searchStr 1 0 0"
     } else {
       set widgets(toolbar,searchfield,e) [::ttk::entry $widgets(toolbar,searchfield).e \
                        -textvariable ::skin::potato::searchStr]
       set widgets(toolbar,searchfield,btn) [::ttk::button $widgets(toolbar,searchfield).b \
                -image ::skin::potato::img::searchGlass \
                -command "::potato::findIn {} \$::skin::potato::searchStr 1 0 0"]
       pack $widgets(toolbar,searchfield,e) -side left -padx 3 -anchor w
       pack $widgets(toolbar,searchfield,btn) -side left -anchor w -expand 0 -fill none
       bind $widgets(toolbar,searchfield,e) <Return> [list $widgets(toolbar,searchfield,btn) invoke]
     }

  set ::skin::potato::searchStr ""
  toolbarLabels

  # Set up the status bar #abc
  foreach x [list worldname hostinfo connstatus clock] {
     set widgets(statusbar,$x) [::ttk::frame $widgets(statusbar).$x -relief sunken -borderwidth 2]
  }
  foreach x [list hostinfo clock] {
     set widgets(statusbar,$x,label) [::ttk::label $widgets(statusbar,$x).l]
     pack $widgets(statusbar,$x,label) -in $widgets(statusbar,$x) -side top -fill none -anchor center
  }
  set widgets(statusbar,worldname,sub) [::ttk::frame $widgets(statusbar,worldname).sub]
  pack $widgets(statusbar,worldname,sub) -in $widgets(statusbar,worldname) -anchor center
  set widgets(statusbar,worldname,label) [::ttk::label $widgets(statusbar,worldname,sub).namel]
  set widgets(statusbar,worldname,label,prompt) [::ttk::label $widgets(statusbar,worldname,sub).prompt]
  pack $widgets(statusbar,worldname,label) -side left -anchor e
  pack $widgets(statusbar,worldname,label,prompt) -side left -anchor w

  set widgets(statusbar,connstatus,sub) [::ttk::frame $widgets(statusbar,connstatus).sub]
  pack $widgets(statusbar,connstatus,sub) -in $widgets(statusbar,connstatus) -anchor center
  set widgets(statusbar,connstatus,sub,msg) [::ttk::label $widgets(statusbar,connstatus,sub).msg -compound left]
  set widgets(statusbar,connstatus,sub,time) [::ttk::label $widgets(statusbar,connstatus,sub).time]
  pack $widgets(statusbar,connstatus,sub,msg) -side left -anchor e
  pack $widgets(statusbar,connstatus,sub,time) -side left -anchor w

  $widgets(statusbar,clock,label) configure -textvariable ::potato::potato(clock)

  grid $widgets(statusbar,worldname) $widgets(statusbar,hostinfo) $widgets(statusbar,connstatus) $widgets(statusbar,clock) -in $widgets(statusbar) -padx 1 -pady 1 -ipady 1 -sticky nswe
  grid rowconfigure $widgets(statusbar) all -weight 1 -uniform status
  grid columnconfigure $widgets(statusbar) all -weight 1 -uniform status

  inputWindows 0 [expr {$::potato::world(-1,twoInputWindows) + 1}]
  showStatusBar

  set skin(init) 1

  return;

};# ::skin::potato::init

#: proc ::skin::potato::showStatusBar
#: desc Show or hide the status bar, depending on $opts(statusbar)
#: return nothing
proc ::skin::potato::showStatusBar {} {
  variable opts;
  variable widgets;

  if { $opts(statusbar) } {
       pack $widgets(statusbar) -in $widgets(main) -side bottom -expand 0 -fill x -anchor s -padx 1 -ipady 1
     } else {
       pack forget $widgets(statusbar)
     }

};# ::skin::potato::showStatusBar

#: proc ::skin::potato::inputWindows
#: arg c connection id
#: arg num Number of input windows to show (either 1 or 2)
#: desc Show $num input windows, hiding extras if necessary
#: return nothing
proc ::skin::potato::inputWindows {c num} {
  variable widgets;

  if { $num == 1 } {
       set hide 1
     } else {
       set hide 0
     }

  if { $c == [::potato::up] } {
       $widgets(pane,btm,pane) paneconfigure $widgets(pane,btm,pane,btm) -hide $hide
     }

  return;

};# ::skin::potato::inputWindows

#: proc ::skin::potato::uninit
#: desc Destroy everything created for the skin when it's unshown. Note: do not unset prefs!
#: return nothing
proc ::skin::potato::uninit {} {
  variable widgets;
  variable idle;
  variable skin;

  array unset widgets conn,*,txtframe,cmd
  array unset widgets *,withInput
  foreach x [array names widgets] {
    destroy $widgets($x)
  }
  unset -nocomplain widgets;
  unset -nocomplain idle;
  foreach x [lsearch -all -inline -glob [image names] ::skin::potato::img::*] {
     image delete $x
  }

  set skin(init) 0

};# ::skin::potato::uninit

#: proc ::skin::potato::toolbarButton
#: arg istask Is $details a task name?
#: arg details Either a task name, or a [list] of long name and command to run for the button
#: arg short The short text to show on the button compound
#: arg image The image to show for the button, in the ::skin::potato::img namespace
#: desc Create a toolbar button for the skin's toolbar, using a Potato Task if $istask is true, or the info in $details otherwise
#: return widget path
proc ::skin::potato::toolbarButton {istask details short image} {
  variable widgets;

  if { $istask } {
       set long [::potato::taskLabel $details]
       set cmd [list ::potato::taskRun $details]
     } else {
       foreach {long cmd} $details {break;}
     }
  if { $short == "" } {
       set short $long
     }
  set btn [::ttk::button "$widgets(toolbar).btn[llength [array names widgets toolbar,*]]" \
                   -text $short -command $cmd -style Toolbutton -takefocus 0]
  if { $image != "" } {
       $btn configure -image "::skin::potato::img::$image" ;#-height 19 -width 19
     }

  ::potato::tooltip $btn $long

  return $btn;

};# ::skin::potato::toolbarButton

#: proc ::skin::potato::toolbarLabels
#: desc Run whenever the "Show Toolbar Labels" option is toggled. Alters the compound for the toolbar button widgets, and changes their padding.
#: return nothing
proc ::skin::potato::toolbarLabels {} {
  variable widgets;
  variable opts;

  if { $opts(toolbarLabels) } {
       set compound "top"
       set padx 3
     } else {
       set compound "none"
       set padx 1
     }
  foreach x [array names widgets toolbar,*] {
     if { [winfo class $widgets($x)] ni [list "Button" "TButton"] } {
          continue;
        }
     $widgets($x) configure -compound $compound
     pack $widgets($x) -padx $padx
  }

  return;

};# ::skin::potato::toolbarLabels

#: proc ::skin::potato::doWorldBarButton
#: arg c connection id
#: desc Create a button for the "World Bar", which has a list of buttons for each connection. Store the widget path in $widgets(woldbar,$c)
#: return nothing
proc ::skin::potato::doWorldBarButton {c} {
  variable widgets;

  set widgets(worldbar,$c) [ttk::button $widgets(worldbar).button-$c -style Toolbutton -command [list ::skin::potato::worldBarButtonClick $c] -compound left]
  bind $widgets(worldbar,$c) <Button-3> [list ::skin::potato::worldBarButtonMenu %W $c %X %Y]

  # BG Colours previously used by the Worldbar buttons to show status, for reference.
  # up #77eecceeee44 newact #ffffbbe77ve7 disconnected #ffff99999999 \
  # normal [ttk::style lookup TFrame -background [$widgets(worldbar) state]]

  worldBarButtonNames

  return;

};# ::skin::potato::doWorldBarButton

#: proc ::skin::potato::worldBarButtonNames
#: desc Trim the names of the worldbar buttons as needed, and repack them all in the correct order
#: return nothing
proc ::skin::potato::worldBarButtonNames {} {
  variable widgets;

  set len [llength [array names widgets worldbar,*]]
  if { $len >= 20 } {
       set clip 6
     } elseif { $len >= 15 } {
       set clip 9
     } elseif { $len >= 8 } {
       set clip 18
     } else {
       set clip 30
     }
  set after [list]
  foreach x [lsort -dictionary [array names widgets worldbar,*]] {
     foreach {tmp c} [split $x ,] {break;}
     set name "$c. [::potato::connInfo $c connname]"
     ::potato::tooltip $widgets($x) $name
     if { [string length $name] > [expr {$clip + 3}] } {
          $widgets($x) configure -text "[string range $name 0 $clip]..."
        } else {
          $widgets($x) configure -text $name
        }
     pack $widgets($x) -in $widgets(worldbar) -side left -anchor nw -padx 6 -pady 6 {*}$after
     set after [list -after $widgets($x)]
  }

  return;

};# ::skin::potato::worldBarButtonNames

#: proc ::skin::potato::worldBarButtonClick
#: arg c connection id
#: desc Handle a click on the worldbar button for connection $c. If the connection is not up, show it. If it is up, but we're showing one of it's spawns instead, reshow the main window
#: return nothing
proc ::skin::potato::worldBarButtonClick {c} {

  if { [::potato::up] != $c } {
       ::potato::showConn $c
       return;
     }

  showSpawn $c ""

  return;

};# ::skin::potato::worldBarButtonClick

#: proc ::skin::potato::worldBarButtonMenu
#: arg btn Widget path of button to post for
#: arg c connection id
#: arg x X-coord for posting
#: arg y Y-coord for posting
#: desc Show a menu to let the user reconnect, disconnect or close the connection
#: return nothing
proc ::skin::potato::worldBarButtonMenu {btn c x y} {
  variable widgets;

  set m $widgets(worldbarRightclickMenu)
  $m delete 0 end

  ::potato::createMenuTask $m reconnect $c $c
  ::potato::createMenuTask $m disconnect $c $c
  ::potato::createMenuTask $m close $c $c
  tk_popup $m $x $y

};# ::skin::potato::worldBarButtonMenu

#: proc ::skin::potato::viewMenuPost
#: arg menu The widget path of the view menu
#: desc REQUIRED by the skin spec. Called when the "View" menu is posted so we can add skin-specific items
#: return nothing
proc ::skin::potato::viewMenuPost {menu} {
  variable widgets;

  $menu add separator
  $menu add checkbutton {*}[::potato::menu_label [::potato::T "Show World Toolbar?"]] -variable ::skin::potato::opts(worldbar) \
            -command ::skin::potato::worldBar
  $menu add checkbutton  {*}[::potato::menu_label [::potato::T "Show Spawn Toolbar?"]] -variable ::skin::potato::opts(spawnbar) \
            -command ::skin::potato::spawnBar
  $menu add checkbutton  {*}[::potato::menu_label [::potato::T "Show Status Bar?"]] -variable ::skin::potato::opts(statusbar) \
            -command ::skin::potato::showStatusBar
  set c [::potato::up]
  if { $c == 0 || [llength [::potato::connInfo $c spawns]] == 0 } {
       set state "disabled"
     } else {
       set state "normal"
     }
  if { ![info exists widgets(viewmenuSpawns)] || ![winfo exists $widgets(viewmenuSpawns)] } {
       set widgets(viewmenuSpawns) [menu $menu.spawns -tearoff 0 -postcommand [list ::skin::potato::spawnMenuPost]]
     }
  $menu add cascade  {*}[::potato::menu_label [::potato::T "&Spawns"]] -menu $widgets(viewmenuSpawns) -state $state
  $menu add checkbutton  {*}[::potato::menu_label [::potato::T "Show Toolbar &Labels?"]] -variable ::skin::potato::opts(toolbarLabels) \
            -command ::skin::potato::toolbarLabels

  return;

};# ::skin::potato::viewMenuPost

#: proc ::skin::potato::spawnMenuPost
#: desc Called when the Spawn menu (inside the View menu) is posted; rebuilds the menu so it's up to date
#: return nothing
proc ::skin::potato::spawnMenuPost {} {
  variable widgets;
  variable disp;

  set c [::potato::up]
  set menu $widgets(viewmenuSpawns)
  $menu delete 0 end

  set disp(spawnMenu) $disp([::potato::up])

  $menu add checkbutton  {*}[::potato::menu_label [::potato::T "Main Window"]] -command [list ::skin::potato::showSpawn $c ""] -variable ::skin::potato::disp(spawnMenu) -onvalue ""

  $menu add separator

  foreach x [lsort -dictionary -index 0 [::potato::connInfo $c spawns]] {
    set name [lindex $x 0]
    $menu add checkbutton -label $name -command [list ::skin::potato::showSpawn $c $name] -variable ::skin::potato::disp(spawnMenu) -onvalue $name
  }

  return;

};# ::skin::potato::spawnMenuPost

#: proc ::skin::potato::status
#: arg c connection id
#: desc REQUIRED by the skin protocol. Called when the status of connection $c changes. Updates the status of the connection everywhere in the skin
#: return nothing
proc ::skin::potato::status {c} {
  variable widgets;
  variable idle;

  set status [::potato::status $c]
  set cstatus [::potato::connStatus $c]

  if { $c != 0 && $cstatus != "closed" } {
       if { ![info exists widgets(worldbar,$c)] } {
            doWorldBarButton $c
          } else {
            worldBarButtonNames
          }
     }

  if { [::potato::up] == $c } {
       # We should never get "closed" for this, because it'll be unshown'n first.
       if { [set pos [lsearch -exact $idle(ids) $c]] != -1 } {
            set idle(ids) [lreplace $idle(ids) $pos $pos]
            set idle(list) [lreplace $idle(list) $pos $pos]
         }
       catch {$widgets(worldbar,$c) configure -image ::skin::potato::img::worldbarUp}
       if { $c == 0 } {
            $widgets(toolbar,disconnect) configure -state disabled
            $widgets(toolbar,reconnect) configure -state disabled
            $widgets(toolbar,close) configure -state disabled
            $widgets(statusbar,connstatus,sub,msg) configure -text [::potato::T "Not Connected"] -image {}
            $widgets(statusbar,hostinfo,label) configure -text [::potato::T "Not Connected"]
          } elseif { $status == "disconnected" } {
            if { [::potato::connInfo $c autoreconnect] } {
                 $widgets(toolbar,disconnect) configure -state normal
               } else {
                 $widgets(toolbar,disconnect) configure -state disabled
               }
            $widgets(toolbar,reconnect) configure -state normal
            $widgets(toolbar,close) configure -state normal
            set recontime [potato::connInfo $c autoreconnect,time]
            if { $recontime == 0 || ![potato::connInfo $c autoreconnect] } {
                 $widgets(statusbar,connstatus,sub,msg) configure -text [::potato::T "Not Connected"] -image {}
               } else {
                 $widgets(statusbar,connstatus,sub,msg) configure -image {} \
                       -text [::potato::T "Not Connected - Reconnect Every %s" [potato::timeFmt $recontime 0]]
               }
          } elseif { $cstatus == "connecting" } {
            $widgets(toolbar,disconnect) configure -state normal;# cancel reconnect
            $widgets(toolbar,reconnect) configure -state disabled
            $widgets(toolbar,close) configure -state normal
            $widgets(statusbar,connstatus,sub,msg) configure -text [::potato::T "Connecting..."] -image {}
          } else {
            $widgets(toolbar,disconnect) configure -state normal
            $widgets(toolbar,reconnect) configure -state disabled
            $widgets(toolbar,close) configure -state normal
            $widgets(statusbar,connstatus,sub,msg) configure -text [::potato::T "Connected For:"]
            if { [::potato::hasProtocol $c ssl] } {
                 $widgets(statusbar,connstatus,sub,msg) configure -image ::skin::potato::img::ssl
               } else {
                 $widgets(statusbar,connstatus,sub,msg) configure -image {}
               }
          }
     } else {
       if { $status == "closed" } {
            if { [set pos [lsearch -exact $idle(ids) $c]] != -1 } {
                 set idle(ids) [lreplace $idle(ids) $pos $pos]
                 set idle(list) [lreplace $idle(list) $pos $pos]
               }
            catch {destroy $widgets(worldbar,$c)}
            foreach x [array names widgets conn,$c,*] {
               destroy $x
            }
            unset -nocomplain widgets(worldbar,$c)
            array unset widgets conn,$c,*
          } elseif { $status == "idle" } {
            if { [set pos [lsearch -exact $idle(ids) $c]] == -1 } {
                 lappend idle(ids) $c
                 set idle(ids) [lsort $idle(ids)]
                 set tmplist [list]
                 foreach x $idle(ids) {
                    lappend tmplist "$x. [::potato::connInfo $x name]"
                 }
                 set idle(list) $tmplist
               }
            catch {$widgets(worldbar,$c) configure -image ::skin::potato::img::worldbarNewact}
          } elseif { $status == "disconnected" } {
            catch {$widgets(worldbar,$c) configure -image ::skin::potato::img::worldbarDc}
          } else {
            catch {$widgets(worldbar,$c) configure -image ::skin::potato::img::worldbarNormal}
          }
     }
  updateTaskButtons
  if { $c == 0 || [llength [array names widgets worldbar,*]] < 2 } {
       $widgets(toolbar,prev) configure -state disabled
       $widgets(toolbar,toggle) configure -state disabled
       $widgets(toolbar,next) configure -state disabled
     } else {
       $widgets(toolbar,prev) configure -state normal
       $widgets(toolbar,toggle) configure -state normal
       $widgets(toolbar,next) configure -state normal
    }

  worldBarButtonNames
  if { [set pos [lsearch $idle(ids) $c]] != -1 } {
       set idle(list) [lreplace $idle(list) $pos $pos "$c. [::potato::connInfo $c name]"]
     }


  return;

};# ::skin::potato::status

#: proc ::skin::potato::updateTaskButtons
#: desc Update all the buttons which run tasks, based on the states of their tasks
#: return nothing
proc ::skin::potato::updateTaskButtons {} {
  variable widgets;

  set states [list disabled normal]

  $widgets(toolbar,config) configure -state [lindex $states [::potato::taskState config]]
  $widgets(toolbar,events) configure -state [lindex $states [::potato::taskState events]]
  $widgets(toolbar,log) configure -state [lindex $states [::potato::taskState log]]
  $widgets(toolbar,upload) configure -state [lindex $states [::potato::taskState upload]]
  $widgets(toolbar,mailWindow) configure -state [lindex $states [::potato::taskState mailWindow]]
  $widgets(toolbar,find) configure -state [lindex $states [::potato::taskState find]]
  if { [::potato::taskState find] } {
       $widgets(toolbar,searchfield,e) state !disabled
       $widgets(toolbar,searchfield,e) configure -cursor xterm
       catch {$widgets(toolbar,searchfield,btn) state !disabled};# only exists on some platforms
     } else {
       $widgets(toolbar,searchfield,e) state disabled
       $widgets(toolbar,searchfield,e) configure -cursor {}
       catch {$widgets(toolbar,searchfield,btn) state disabled};# only exists on some platforms
     }


};# ::skin::potato::updateTaskButtons

#: proc ::skin::potato::packskin
#: desc REQUIRED by the skin protocol. Pack the skin into window "."
#: return nothing
proc ::skin::potato::packskin {} {
  variable widgets;
  variable skin;

  if { ![info exists skin(init)] || !$skin(init) } {
       init;
     }

  pack $widgets(main) -in . -expand 1 -fill both -anchor nw
#tk_messageBox -message "Ping"
  return;

};# ::skin::potato::packskin

#: proc ::skin::potato::unpackskin
#: desc REQUIRED by the skin protocol. Unpack the skin from window "."
#: return nothing
proc ::skin::potato::unpackskin {} {
  variable widgets;

  pack forget $widgets(main)
  uninit

  return;

};# ::skin::potato::unpackskin

#: proc ::skin::potato::worldBar
#: arg c connection id. Defaults to ""
#: desc Called when we change to viewing a different connection, and when the "Show World Toolbar" option is toggled. Show/hide the World Toolbar as necessary. (Hide if it's turned off or we have no open connections, else show.)
#: return nothing
proc ::skin::potato::worldBar {{c ""}} {
  variable widgets;
  variable opts;

  if { $c == "" } {
       set c [potato::up]
     }

  if { $c == 0 || !$opts(worldbar) } {
       pack forget $widgets(worldbar)
     } else {
       pack $widgets(worldbar) -in $widgets(main) -side top -expand 0 -fill x -anchor nw -after $widgets(toolbar)
     }

  return;

};# ::skin::potato::worldBar

#: proc ::skin::potato::show
#: arg c connection id
#: desc REQUIRED by the skin protocol. Show connection $c. This does no unpacking of other connections, as that's already handled elsewhere.
#: return nothing
proc ::skin::potato::show {c} {
  variable widgets;
  variable opts;

  ::skin::potato::worldBar $c
  ::skin::potato::spawnBar $c

  set input1 [::potato::connInfo $c input1]
  set input2 [::potato::connInfo $c input2]

  pack $input1 -in $widgets(pane,btm,pane,top) -side left -expand 1 -fill both -anchor nw
  pack $input2 -in $widgets(pane,btm,pane,btm) -side left -expand 1 -fill both -anchor nw

  $input1 configure -yscrollcommand [list $widgets(pane,btm,pane,top,sb) set]
  $widgets(pane,btm,pane,top,sb) configure -command [list $input1 yview]
  $input2 configure -yscrollcommand [list $widgets(pane,btm,pane,btm,sb) set]
  $widgets(pane,btm,pane,btm,sb) configure -command [list $input2 yview]

  $widgets(pane,top) configure -background [::potato::connInfo $c top,bg]
  $widgets(conn,$c,txtframe) configure -background [::potato::connInfo $c top,bg]

  $widgets(pane,btm,idle) configure -background [::potato::connInfo $c bottom,bg] \
                      -foreground [::potato::connInfo $c bottom,fg] -font [::potato::connInfo $c bottom,font]

  set btm(font) [::potato::connInfo $c bottom,font]
  set btm(fg) [::potato::connInfo $c bottom,fg]
  set btm(bg) [::potato::connInfo $c bottom,bg]
  set btm(insert) [::potato::reverseColour $btm(bg)]

  if { [info exists widgets(conn,$c,withInput)] } {
       focus $widgets(conn,$c,withInput)
     } else {
       focus [set input[::potato::connInfo $c inputFocus]]
     }

  update idletasks
  pack $widgets(conn,$c,txtframe) -in $widgets(pane,top) -side left -expand 1 -fill both -anchor nw -pady 0 -padx [list 3 0]
  fixWindowOrder $c

  if { $c == 0 } {
       $widgets(statusbar,worldname,label) configure -text $::potato::potato(name)
       $widgets(statusbar,hostinfo,label) configure -text [::potato::T "Not Connected"]
       $widgets(statusbar,connstatus,sub,msg) configure -text [::potato::T "Not Connected"] -image {}
       $widgets(statusbar,worldname,label,prompt) configure -textvariable ""
    } else {
       $widgets(statusbar,worldname,label) configure -text "$c. [potato::connInfo $c name]"
       $widgets(statusbar,hostinfo,label) configure -text "[potato::connInfo $c host]:[potato::connInfo $c port]"
       $widgets(statusbar,worldname,label,prompt) configure -textvariable ::potato::conn($c,prompt)
    }

  $widgets(statusbar,connstatus,sub,time) configure -textvariable ::potato::conn($c,stats,formatted)
  updateTaskButtons

  return;

};# ::skin::potato::show

#: proc ::skin::potato::fixWindowOrder
#: arg c connection id
#: desc raise all the windows when we show conn $c to get the tab order correct.
#: return nothing
proc ::skin::potato::fixWindowOrder {c} {
  variable widgets;

  foreach x [list $widgets(toolbar) $widgets(worldbar) $widgets(spawnbar) $widgets(conn,$c,txtframe) \
                  [::potato::connInfo $c input1] [::potato::connInfo $c input2] $widgets(pane,btm,idle)] {
    if { [winfo exists $x] && [winfo manager $x] ne "" } {
         raise $x
       }
  }

  return;

};# ::skin::potato::fixWindowOrder

#: proc ::skin::potato::unshow
#: arg c connection id
#: desc REQUIRED by the skin protocol. Unpack connection $c from the display.
#: return nothing
proc ::skin::potato::unshow {c} {
  variable widgets;
  variable spawns;

  set input1 [::potato::connInfo $c input1]
  set input2 [::potato::connInfo $c input2]

  set widgets(conn,$c,withInput) [set input[::potato::connInfo $c inputFocus]]

  $input1 configure -yscrollcommand ""
  $widgets(pane,btm,pane,top,sb) configure -command ""
  $input2 configure -yscrollcommand ""
  $widgets(pane,btm,pane,btm,sb) configure -command ""
  pack forget $widgets(conn,$c,txtframe) $input1 $input2
  catch {wm withdraw $widgets(conn,$c,find)}
  catch {destroy {*}[winfo children $widgets(spawnbar)]}

  worldBarButtonNames

  array unset spawns $c,*

  return;

};# ::skin::potato::unshow

#: proc ::skin::potato::activeTextWidget
#: arg c connection id. Defaults to ""
#: desc REQUIRED by the skin spec. Return the path of the text widget currently displayed for connection $c, or the current connection if $c is "" (main text widget or spawn window)
#: return text widget path
proc ::skin::potato::activeTextWidget {{c ""}} {
  variable disp;

  if { $c eq "" } {
       set c [::potato::up]
     }

  if { ![info exists disp($c)] || $disp($c) eq "" } {
       return [potato::connInfo $c textWidget];
     } else {
       set pos [::potato::findSpawn $c $disp($c)]
       if { $pos == -1 } {
            return [::potato::connInfo $c textWidget];
          } else {
            set spawn [lindex [::potato::connInfo $c spawns] $pos]
            return [lindex $spawn 1];
          }
     }

};# ::skin::potato::activeTextWidget

#: proc ::skin::potato::linkCopy
#: arg t text widget
#: arg index index of click
#: desc Copy the weblink from text widget $t at index $index to the clipboard
#: return nothing
proc ::skin::potato::linkCopy {t index} {

  if { ![catch {set data [$t get {*}[$t tag prevrange "weblink" "$index + 1 char"]]} foo] } {
       clipboard clear -displayof $t
       clipboard append -displayof $t $data
     } else {
       bell -displayof .
     }

  return;

};# ::skin::potato::linkCopy

#: proc ::skin::potato::rightclickOutput
#: arg c connection id
#: arg t text widget, or "" for active text widget
#: arg evx %x event substitution
#: arg evy %y event substitution
#: arg evX %X event substitution
#: arg evY %Y event substitution
#: desc Handle a right-click in text widget $t (or connection $c's active text widget, if $t is ""), at coordinates $atX,$atY. Update the right-click menu and then post it.
#: return nothing
proc ::skin::potato::rightclickOutput {c t evx evy evX evY} {
  variable widgets;

  set menu $widgets(rightclickOutputMenu)
  $menu delete 0 end
  ::potato::createMenuTask $menu nextConn
  $menu add command {*}[::potato::menu_label [::potato::T "&Copy Selected Text"]]
  $menu add command {*}[::potato::menu_label [::potato::T "Copy &Hyperlink"]]
  if { $c == 0 } {
       ::potato::createMenuTask $menu programConfig
     } else {
       ::potato::createMenuTask $menu config
     }
  if { $t eq "" } {
       set t [activeTextWidget $c]
     }
  if { [winfo class $t] ne "Text" } {
       return;
     }
  set conns [lsort -integer -index 0 [::potato::connList]]
  if { $c == 0 || [llength $conns] < 2 } {
       $menu entryconfigure 0 -state disabled
     } else {
       $menu entryconfigure 0 -state normal
     }
  if { [$t tag nextrange sel 1.0] eq "" } {
       $menu entryconfigure 1 -state disabled
     } else {
       $menu entryconfigure 1 -state normal -command [list event generate $t <<Copy>>]
     }
  if { "weblink" in [$t tag names @$evx,$evy] } {
       $menu entryconfigure 2 -state normal -command [list ::skin::potato::linkCopy $t [$t index @$evx,$evy]]
     } else {
       $menu entryconfigure 2 -state disabled
     }
  $menu add separator
  $menu add command {*}[::potato::menu_label [::potato::T "Clear Output Buffer"]] -command [list ::potato::clearOutputWindow $c $t]
  if { $c != 0 } {
       $menu add separator
       foreach x $conns {
          foreach {id name status} $x {break}
          $menu add command -label "$id. $name" -command [list ::potato::showConn $id]
       }
     }

  tk_popup $menu $evX $evY

  return;

};# ::skin::potato::rightclickOutput

#: proc ::skin::potato::rightclickSpawnBar
#: arg c connection id
#: arg name spawn name
#: arg evx %x event substitution
#: arg evy %y event substitution
#: arg evX %X event substitution
#: arg evY %Y event substitution
#: desc Handle a right-click on the button for conn $c's spawn $name on the spawn toolbar
#: return nothing
proc ::skin::potato::rightclickSpawnBar {c name evx evy evX evY} {
  variable widgets;

  # We reuse this, since it's only ever displayed in one place at a time, and all entries are deleted prior to display
  set menu $widgets(rightclickOutputMenu)
  $menu delete 0 end
  $menu add command {*}[::potato::menu_label [::potato::T "&Close Spawn"]] -command [list ::potato::destroySpawnWindow $c $name]

  tk_popup $menu $evX $evY

  return;

};# ::skin::potato::rightClickSpawnBar


#: proc ::skin::potato::import
#: arg c connection id
#: desc REQUIRED by the skin protocol. Start managing connection $c in this skin; create any widgets needed, set vars, etc. The connection's text widgets can be packed into appropriate frames, etc, but should not be displayed on screen.
#: return nothing
proc ::skin::potato::import {c} {
  variable widgets;

  set t [::potato::connInfo $c text]

  set widgets(conn,$c,txtframe) [frame $widgets(pane,top).txtframe-$c]
  set widgets(conn,$c,txtframe,cmd) ::skin::potato::conn_${c}_txtframe_cmd
  rename $widgets(conn,$c,txtframe) $widgets(conn,$c,txtframe,cmd)
  proc ::$widgets(conn,$c,txtframe) {first args} [string map [list CONNID $c] {
    if { $first == "yview" } {
         [::skin::potato::activeTextWidget CONNID] yview {*}$args
       } else {
         ::skin::potato::conn_CONNID_txtframe_cmd $first {*}$args
       }
  }]

  set widgets(conn,$c,txtframe,sb) [::ttk::scrollbar $widgets(conn,$c,txtframe).sb -orient vertical]

  pack $widgets(conn,$c,txtframe,sb) -side right -fill y -anchor ne

  bind $widgets(conn,$c,txtframe) <MouseWheel> [list ::skin::potato::scrollActiveTextWidget $c %D]
  bind $widgets(conn,$c,txtframe) <Button-3> [list ::skin::potato::rightclickOutput $c "" %x %y %X %Y]

  bind $t <Button-3> [list ::skin::potato::rightclickOutput $c $t %x %y %X %Y]

  foreach x [::potato::connInfo $c spawns] {
    addSpawn $c $x
  }

  showSpawn $c ""

  return;

};# ::skin::potato::import

#: proc ::skin::potato::scrollActiveTextWidget
#: arg c connection id
#: arg delta The %D sub from the <MouseWheel> event
#: desc Scroll the active text widget for connection $c
#: return nothing
proc ::skin::potato::scrollActiveTextWidget {c delta} {

  ::potato::mouseWheel [activeTextWidget $c] $delta
  return;

};# ::skin::potato::scrollActiveTextWidget

#: proc ::skin::potato::export
#: arg c connection id
#: desc REQUIRED by the skin protocol. Stop managing connection $c in this skin; unpack all it's widgets and destroy any skin-specific widgets (and unset skin-specific vars) created to handle this connection and it's spawns in this skin.
#: return nothing
proc ::skin::potato::export {c} {
  variable widgets;
  variable disp;

  foreach x [::potato::connInfo $c spawns] {
    delSpawn $c $x
  }

  set t [::potato::connInfo $c textWidget]
  pack forget $t [::potato::connInfo $c input1] [::potato::connInfo $c input2]

  bind $t <Button-3> {}
  $t configure -yscrollcommand {}

  foreach x [array names widgets conn,$c,*] {
     catch {destroy $widgets($x)}
  }

  catch {array unset widgets conn,$c,*}
  unset -nocomplain disp($c)
  return;

};# ::skin::potato::export

#: proc ::skin::potato::idleClick
#: desc Handle a click on the listbox showing connections with new activity
#: return nothing
proc ::skin::potato::idleClick {} {
  variable widgets;
  variable idle;

  set world [$widgets(pane,btm,idle) curselection]
  if { $world eq "" } {
       return;
     }
  set world [lindex $idle(ids) $world]
  if { $world ne "" } {
       ::potato::showConn $world
     }

  return;

};# ::skin::potato::idleClick

#: proc ::skin::potato::toggleMenu
#: desc Rebuild the menu listing all the current connections and post it near the Toggle Connection toolbar button. Called when said button is clicked.
#: return nothing
proc ::skin::potato::toggleMenu {} {
  variable widgets;

  $widgets(togglemenu) unpost
  $widgets(togglemenu) delete 0 end
  set list [lsort -integer -index 0 [::potato::connList]]
  if { [llength $list] > 0 } {
       foreach x $list {
         foreach {c name status} $x {break}
         $widgets(togglemenu) add command -label "$c. $name" -command [list ::potato::showConn $c]
       }
       set atX [winfo rootx $widgets(toolbar,toggle)]
       set atY [expr [winfo rooty $widgets(toolbar,toggle)]+[winfo height $widgets(toolbar,toggle)]]
       tk_popup $widgets(togglemenu) $atX $atY
     } else {
       bell -displayof $widgets(toolbar,toggle)
     }

  return;

};# ::skin::potato::toggleMenu

#: proc ::skin::potato::connectMenu
#: desc Calculate where to show the "Connect To..." menu, then call the "connectMenu" task with those coordinates
#: return nothing
proc ::skin::potato::connectMenu {} {
  variable widgets;

  set atX [winfo rootx $widgets(toolbar,connect)]
  set atY [expr [winfo rooty $widgets(toolbar,connect)]+[winfo height $widgets(toolbar,connect)]]

  ::potato::taskRun connectMenu "" $atX $atY

  return;

};# ::skin::potato::connectMenu

#: proc ::skin::potato::addSpawn
#: arg c connection id
#: arg sinfo List of spawn name and its output and 2 input widgets
#: desc REQUIRED by the skin protocol. Display the new spawn widget $name, created for connection $c.
#: return nothing
proc ::skin::potato::addSpawn {c sinfo} {

  if { [::potato::up] == $c } {
       spawnBar $c
     }

  foreach [list name t i1 i2] $sinfo {break}
  bind $t <Button-3> [list ::skin::potato::rightclickOutput $c $t %x %y %X %Y]

  return;

};# ::skin::potato::addSpawn

#: proc ::skin::potato::spawnBar
#: arg c connection id. Defaults to ""
#: desc Set up the buttons on the Spawn Bar for connection $c, or the currently shown connection if $c is ""
#: return nothing
proc ::skin::potato::spawnBar {{c ""}} {
  variable widgets;
  variable opts;
  variable disp;
  variable spawns;

  if { $c eq "" } {
       set c [::potato::up]
     }
  catch {destroy {*}[winfo children $widgets(spawnbar)]}
  if { !$opts(spawnbar) } {
       catch {pack forget $widgets(spawnbar)}
       fixWindowOrder $c
       return;
     }

  foreach x [lsort -dictionary -index 0 [::potato::connInfo $c spawns]] {
     set name [lindex $x 0]
     set btn $widgets(spawnbar).spawn_$name
     ttk::button $btn -text $name -command [list ::skin::potato::showSpawn $c $name] -style Toolbutton -compound left
     if { [info exists disp($c)] && $disp($c) eq $name } {
          $btn configure -image ::skin::potato::img::spawnbarUp
        } elseif { [info exists spawns($c,$name)] } {
          $btn configure -image ::skin::potato::img::worldbarNewact
        } else {
          $btn configure -image ::skin::potato::img::spawnbarNormal
        }
     pack $btn -side left -padx 8 -pady 5
     bind $btn <Button-3> [list ::skin::potato::rightclickSpawnBar $c $name %x %y %X %Y]
  }

  if { ![llength [winfo children $widgets(spawnbar)]] } {
       catch {pack forget $widgets(spawnbar)}
     } else {
       catch {pack $widgets(spawnbar) -in $widgets(main) -side top -expand 0 -fill x -anchor nw -after $widgets(worldbar)}
     }

  fixWindowOrder $c

  return;

};# ::skin::potato::spawnBar

#: proc ::skin::potato::spawnUpdate
#: arg c connection id
#: arg spawn name of spawn updated
#: desc REQUIRED by the skin protocol. Mark new activity for conn $c's spawn $spawn
proc ::skin::potato::spawnUpdate {c spawn} {
  variable widgets;
  variable opts;
  variable disp;
  variable spawns;

  if { $c ne [::potato::up] || !$opts(spawnbar)} {
       # We don't care right now
       return;
     }

  if { [info exists disp($c)] && $disp($c) eq $spawn } {
       return;
     }

  $widgets(spawnbar).spawn_$spawn configure -image ::skin::potato::img::worldbarNewact
  set spawns($c,$spawn) 1

  return;

};# ::skin::potato::spawnUpdate

#: proc ::skin::potato::delSpawn
#: arg c connection id
#: arg name Spawn name
#: desc REQUIRED by the skin protocol. Stop displaying spawn $name for connection $c; destroy anything created for handling it
#: return nothing
proc ::skin::potato::delSpawn {c name} {
  variable widgets;
  variable disp;
  variable spawns;

  if { $disp($c) eq $name } {
       showSpawn $c ""
     }
  if { [info exists ::potato::conn($c,spawns,$name)] } {
       bind $::potato::conn($c,spawns,$name) <Button-3> {}
     }
  catch {destroy $widgets(spawnbar).spawn_$name}
  if { [::potato::up] == $c } {
       spawnBar $c
     }
  unset -nocomplain spawns($c,$name)
  return;

};# ::skin::potato::delSpawn

#: proc ::skin::potato::showSpawn
#: arg c connection id
#: arg spawn Spawn name
#: desc REQUIRED BY THE SKIN SPEC. For connection $c, show the spawn $spawn (or the main text widget, if $spawn is "", "_main", "Main Window"). The skin spec does not designate how it should be shown, only that it should. For this skin, we remove any text widget currently shown, and display it in place of the main text window for the connection.
#: return nothing
proc ::skin::potato::showSpawn {c spawn} {
  variable disp;
  variable widgets;
  variable spawns;

  if { [lsearch -nocase -exact [list "" "_main" "Main Window"] $spawn] > -1 } {
       set spawn ""
     }

  if { [info exists disp($c)] } {
       # We're already showing something
       if { $disp($c) eq $spawn } {
            # We're already showing the right thing.
            return;
          }
       # Remove what we're showing
       set t [activeTextWidget $c]
       pack forget $t
       $t configure -yscrollcommand {}
       if { $disp($c) ne "" && [winfo exists $widgets(spawnbar).spawn_$disp($c)] } {
            $widgets(spawnbar).spawn_$disp($c) configure -image ::skin::potato::img::spawnbarNormal
          }
     }

  set disp($c) $spawn
  unset -nocomplain spawns($c,$spawn)
  set t [activeTextWidget $c]
  pack $t -in $widgets(conn,$c,txtframe) -expand 0 -fill y -side left -anchor nw -padx 3 -pady 6
  raise $t
  $t configure -yscrollcommand [list $widgets(conn,$c,txtframe,sb) set]
  $widgets(conn,$c,txtframe,sb) configure -command [list $t yview]
  if { $disp($c) ne "" } {
       $widgets(spawnbar).spawn_$disp($c) configure -image ::skin::potato::img::spawnbarUp
     }

  return;

};# ::skin::potato::showSpawn

#: proc ::skin::potato::savePrefs
#: desc REQUIRED by the skin spec. Save skin-specific config.
#: return nothing
proc ::skin::potato::savePrefs {} {
  variable skin;
  variable opts;
  variable widgets;

  if { [catch {open $skin(preffile) w+} fid] } {
       tk_messageBox -title $skin(name) -message "Unable to save skin prefs to \"[file nativename [file normalize $skin(preffile)]]\": $fid" -icon error -type ok
       return;
     }
  inputWindows 2
  update
  set opts(input1height) [winfo height $widgets(pane,btm,pane,top)]
  set opts(input2height) [winfo height $widgets(pane,btm,pane,btm)]
  set opts(inputheights) [winfo height $widgets(pane,btm,pane)]
  puts $fid [list array set ::skin::potato::opts [array get opts]]
  close $fid

  return;

};# ::skin::potato::savePrefs

proc ::skin::potato::loadPrefs {} {
  variable skin;

  catch {source $skin(preffile)}
  return;

};# ::skin::potato::loadPrefs

#: proc ::skin::potato::locale
#: desc REQUIRED. Called when Potato changes locale, so the skin can update displayed text to the new locale
#: return nothing
proc ::skin::potato::locale {} {

  status [::potato::up]

  return;

};# ::skin::potato::locale

#: proc ::skin::potato::nextSpawn
#: arg c conn id
#: desc REQUIRED. Toggle to the next spawn window for connection $c
#: return nothing
proc ::skin::potato::nextSpawn {c} {
  variable disp;
  variable spawns;

  set cspawns [::potato::connInfo $c spawns]
  if { ![llength $cspawns] } {
       return; # no spawns
     }
  set cspawns [lsort -dictionary -index 0 $cspawns]
  if { ![info exists disp($c)] || $disp($c) eq "" } {
  puts "No disp($c)"
       set next [lindex $cspawns 0 0]
     } else {
       set curr [lsearch -index 0 -exact $cspawns $disp($c)]
       set curr [expr {$curr + 1}]
       puts "disp($c) is $disp($c), and curr is $curr"
       if { $curr == [llength $cspawns] } {
            set next "";# toggle back to main window
          } else {
            set next [lindex $cspawns $curr 0]
          }
     }
  showSpawn $c $next

  return;

};# ::skin::potato::nextSpawn











package provide potato-skin 2.0.0
return "potato";








