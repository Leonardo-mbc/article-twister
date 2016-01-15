class @Rating
    constructor: (user_id) ->
        @user_id = user_id

    rating_enable: ->
        $("[data-news]").draggable
            axis: "x"
            revert: true
            revertDuration: 100
            opacity: 0.7
            handle: '.panel-heading'
            scroll: false

            drag: (e, ui) ->
                x = ui.position.left

                if 150 < x
                    $(ui.helper).removeClass "panel-info"
                        .addClass "panel-success"
                if x < -150
                    $(ui.helper).removeClass "panel-info"
                        .addClass "panel-danger"
                if -150 <= x <= 150
                    $(ui.helper).removeClass "panel-info, panel-danger"
                        .addClass "panel-info"

            stop: (e, ui) =>
                x = ui.position.left
                id = $(ui.helper).data 'news'

                if 150 < x
                    sign = 1
                if x < -150
                    sign = -1
                if -150 <= x <= 150
                    sign = 0

                @push id, sign

        $("[data-role='nps'] a").on 'click', (e) =>
            target = $(e.currentTarget)
            li_tag = $(target).parent()
            ul_tag = $(li_tag).parent()
            news_panel = $(ul_tag).parent()

            $(ul_tag).find("li").removeClass "active"
            $(li_tag).addClass "active"

            news_id = $(news_panel).data "news"
            score = parseInt $(target).text()

            @nps_push news_id, score

    push: (id, sign) ->
        $.ajax
            url: '/articles/push_rate'
            type: 'get'
            data:
                news_id: id
                sign: sign
            dataType: 'json'

            success: (data) ->
                delete plotter.dataset[id]
                title = $("[data-news='#{id}']").find 'h3'
                re = new RegExp "glyphicon-ok", "i"

                if !title.html().match(re)
                    $(title).prepend '<span class="glyphicon glyphicon-ok" aria-hidden="true"></span> '

    nps_push: (id, nps) ->
        $.ajax
            url: '/articles/push_rate'
            type: 'get'
            data:
                news_id: id
                nps: nps
            dataType: 'json'

    show_question: () =>
        $('html,body').animate
            scrollTop: 0,
                duration: 2000
                easing: "easeOutExpo"

        $("[data-role='tuner']").fadeOut 300, ->
            $("[data-role='question']").fadeIn()
