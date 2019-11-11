shinyUI(fluidPage(
  column(5,
         wellPanel(
           style = "padding:25px; margin-top:25px;",
           fluidRow(
             column(6,
                    numericInput("penetracion", label = "Penetracion Target:", min=0, max=100, value = 50),
                    actionButton('actualizar', 'Actualizar Informe')
             ),
             column(6,
                    uiOutput('casos'),
                    div(style="margin-top:-5px", 
                        actionButton('insertBtn', ' + '), 
                        actionButton('removeBtn', ' - '))
             )  
           ),
           div(style="margin-top:10px;border-top:1px solid #ccc; padding-top:8px;",
               span(style="font-weight: bold; display:float-left; width:20%; display:inline-block; padding:3px; margin-right:-5px;", "Site ID"),
               span(style="font-weight: bold; display:float-left; width:50%; display:inline-block; padding:3px; margin-right:-5px;","Alcance del Site"),
               span(style="font-weight: bold; display:float-left; width:30%; display:inline-block; padding:3px; margin-right:-5px;","Peso")
           ),
           tags$div(style="margin-top: -20px; margin-bottom: 30px; -webkit-transform: translate(0px, +20px); -ms-transform: translate(0px, 0px);-moz-transform: translate(0px, 0px);", id = 'placeholder'),
           div(style="margin-top:10px;border-top:1px solid #ccc; padding-top:8px;",
               div(style="font-weight: bold; display:float-left; width:70%; display:inline-block; padding-right:13px; margin-right:-5px; text-align:right;","Suma total % de Sites:"),
               div(style="font-weight: bold; display:float-left; width:30%; display:inline-block; padding:3px; margin-right:-5px;", 
                   div(style="background:white; padding:6px 12px; border: 1px solid #ccc; border-radius:4px; font-weight: bold;", textOutput('text1'))
               )
           )
         )
  ),
  column(7,
         wellPanel(
           style = "background-color: #ffffff; padding:25px; margin-top:25px;",
           downloadButton('downloadData', 'Bajar Datos en Excel'),
           plotOutput('nubeonline', height=500)
         )
  )
))
