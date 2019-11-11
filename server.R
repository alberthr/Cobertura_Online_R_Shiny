library(ggplot2)
library(openxlsx)
library(shiny)

shinyServer(function(input, output, session) {
  
  ## CREO ALGUNAS VARIABLES NECESARIAS
  reactivos <- reactiveValues()
  elementos <- c("Site ID 01")
  reactivos$elementos <- elementos
  idx <- c(1)
  reactivos$idx <- idx
  datos <- data.frame(grp=c(0,0),cobertura=c(0,0))
  reactivos$datos <- datos
  reactivos$porcentajes <- c(20)
  
  ## CREO EL PRIMER SITE
  insertUI(
    selector = '#placeholder',
    ui = tags$div(style="height:38px; vertical-align:middle;",
                  span(style="-webkit-transform: translate(0px, -12px); -ms-transform: translate(0px, -12px);-moz-transform: translate(0px, -12px); display:float-left; width:20%; display:inline-block; padding:3px; margin-right:-5px;", "Site ID 01"),
                  div(style="display:float-left; width:50%; display:inline-block; padding:3px; margin-right:-5px;",selectInput("select1", label = NULL, choices = list("Total Poblacion" = 1, "Alto Alcance" = 2, "Medio Alcance" = 3, "Bajo Alcance" = 4), selected = 1)),
                  div(style="-webkit-transform: translate(0px, -12px); -ms-transform: translate(0px, +18px);-moz-transform: translate(0px, +18px); display:float-left; width:30%; display:inline-block; padding:3px; margin-right:-5px;",numericInput("num1", label = NULL, min=0, max=100, value = 20)),
                  id = 1
    )
  )
  
  
  ## AÑAADO SITES
  observeEvent(input$insertBtn, {
    btn <- input$insertBtn + 1
    numero <- paste0("num",btn)
    selecto <- paste0("select",btn)
    if (btn<10) {
      texto <- paste0('Site ID 0',btn)
    } else {
      texto <- paste0('Site ID ',btn)
    }
    insertUI(
      selector = '#placeholder',
      ui = tags$div(style="height:38px; vertical-align:middle;",
                    span(style="-webkit-transform: translate(0px, -12px); -ms-transform: translate(0px, -12px);-moz-transform: translate(0px, -12px); display:float-left; width:20%; display:inline-block; padding:3px; margin-right:-5px;", texto),
                    div(style="display:float-left; width:50%; display:inline-block; padding:3px; margin-right:-5px;",selectInput(selecto, label = NULL, choices = list("Total Poblacion" = 1, "Alto Alcance" = 2, "Medio Alcance" = 3, "Bajo Alcance" = 4), selected = 1)),
                    div(style="-webkit-transform: translate(0px, -12px); -ms-transform: translate(0px, +18px);-moz-transform: translate(0px, +18px); display:float-left; width:30%; display:inline-block; padding:3px; margin-right:-5px;",numericInput(numero, label = NULL, min=0, max=100, value = 20)),
                    id = btn
      )
    )
    elementos <<- c(elementos, texto)
    reactivos$elementos <- elementos
    idx <<- c(idx, btn)
    reactivos$idx <- idx
  })
  
  ## ELIMINO SITES
  observeEvent(input$removeBtn, {
    if (length(reactivos$idx)>1) {
      removeUI(
        selector = paste0('#', idx[match(input$casos,elementos)])
      )
      nelimino <<- match(input$casos,elementos)
      elementos <<- elementos[-nelimino]
      idx <<- idx[-nelimino]
      reactivos$elementos <- elementos
      reactivos$idx <- idx
    }
  })
  
  ## ACTUALIZO INFORME
  observeEvent(input$actualizar, {
    
    datos <- data.frame(grp=c(0,0),cobertura=c(0,0))
    
    if (sum(unlist(sapply(reactivos$idx, function(x) {input[[paste0("num",x)]]})))==100) {
      
      datos <- reactivos$datos
      
      vx <- sapply(reactivos$idx, function(x) {
        if ((as.numeric(input[[paste0("select",x)]]))==1) {50*input$penetracion/65}
        else if ((as.numeric(input[[paste0("select",x)]]))==2) {35*input$penetracion/65}
        else if ((as.numeric(input[[paste0("select",x)]]))==3) {20*input$penetracion/65}
        else if ((as.numeric(input[[paste0("select",x)]]))==4) {10*input$penetracion/65}
      })
      vy <- sapply(reactivos$idx, function(x) {-0.9})
      vz <- sapply(reactivos$idx, function(x) {525})
      
      porcentajes <- sapply(reactivos$idx, function(x) {input[[paste0("num",x)]]})
      reactivos$porcentajes <- porcentajes
      reactivos
      
      curvagrps <- seq(0,200,10)
      curvacobertura <- sapply(curvagrps, function(i) {
        grps <- i/100 *  porcentajes
        coberturas <- ((vx*(1-exp(-grps/vz))/(1+vy*exp(-grps/vz)))/input$penetracion)
        (1-prod(1-coberturas))*input$penetracion
      })
      
      datos <- data.frame(grp=curvagrps,cobertura=curvacobertura)
    }
    
    reactivos$datos <- datos
    
  })
  
  ## ACTUALIZO INPUT SELECTOR
  output$casos = renderUI({
    insertado <- reactivos$elementos
    selectInput('casos', 'Sites Planificados:', insertado)
  })
  
  ## GRAFICO NUBE DE PUNTOS
  output$nubeonline <- renderPlot({
    
    datos <- reactivos$datos
    
    grafico <-ggplot(datos, aes(grp, cobertura)) +
      geom_point(shape=19, size=5, color='darkblue') +
      geom_line(color='darkblue') + 
      ggtitle("Representacion Grafica de Datos\n") + 
      scale_y_continuous(limits = c(0, 100)) +
      theme(plot.title = element_text(lineheight=1.2, face="bold")) +
      ylab("Cobertura (%)") + xlab("GRPs")
    print(grafico)
  })
  
  ## ACTUALIZO PORCENTAJE
  output$text1 <- renderText({ 
    sum(unlist(sapply(reactivos$idx, function(x) {input[[paste0("num",x)]]})))
  })
  
  ## DOWNLOAD INFORMACION
  output$downloadData <- downloadHandler(
    filename = function() { paste("datos", '.xlsx', sep='') },
    content = function(file) {
      datos <- reactivos$datos
      write.xlsx(datos, file, row.names=F)
    }
  )
})