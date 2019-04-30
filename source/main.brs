Function RunScreenSaver(params as Object) as Object 'This function is required for screensavers. It acts as a main method for screensavers
    main()
End Function

sub main()
    m.config = ReadAsciiFile("pkg:/config.json")
    m.config = ParseJSON(m.config)

    screen = createObject("roSGScreen") 'Creates screen to display screensaver

    port = createObject("roMessagePort") 'Port to listen to events on screen
    screen.setMessagePort(port)

    m.zip = getZip()

    m.global = screen.getGlobalNode()
    m.global.AddFields({"BackgroundUri": "", "Weather": {}})

    counter = 0

    scene = screen.createScene("UnsplashScreensaver") 'Creates scene to display on screen. Scene name (AnimatedScreensaver) must match ID of XML Scene Component
    screen.show()

    m.global.BackgroundUri = getBackground()
    m.global.Weather = getWeather()

    while(true) 'Uses message port to listen if channel is closed
        msg = wait(1, port)
        counter++
        if (msg <> invalid)
            msgType = type(msg)
            if msgType = "roSGScreenEvent"
                if msg.isScreenClosed() then return
            end if
        else if counter = 1800000 ' 30 minutes
            m.global.BackgroundUri = getBackground()
            m.global.Weather = getWeather()
            counter = 0
        end if
    end while
end sub

Function getBackground()
    request = CreateObject("roUrlTransfer")
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    request.SetUrl("https://api.unsplash.com/photos/random?orientation=landscape&features=true")
    request.AddHeader("Authorization", "Client-ID " + m.config.unsplash_api_key)
    response = request.GetToString()

    if(response <> "")
        json = ParseJSON(response)

        if(json <> invalid)
            return json.urls.regular
        else
            return invalid
        end if
    else
        return invalid
    end if
end Function

Function getZip()
    request = CreateObject("roUrlTransfer")
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    request.SetUrl("http://api.ipstack.com/check?access_key="+m.config.ipstack_api_key)
    response = request.GetToString()

    if(response <> "")
        json = ParseJSON(response)

        if(json <> invalid)
            return json.zip
        else
            return invalid
        end if
    else
        return invalid
    end if
end Function

'Weather functions
Function getWeather()
    request = CreateObject("roUrlTransfer")
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    request.SetUrl("https://api.openweathermap.org/data/2.5/weather?zip="+m.zip+"&APPID="+m.config.openweathermap_api_key)
    response = request.GetToString()

    if(response <> "")
        json = ParseJSON(response)

        if(json <> invalid)
            return json
        else
            return invalid
        end if
    else
        return invalid
    end if
end Function