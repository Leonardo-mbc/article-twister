class @CheckedAfter
    constructor: () ->
        @selected = []

    select_triger: () ->
        $("[data-news]").on "click", (e) =>
            target = $(e.currentTarget)
            news_id = $(target).data "news"
            sign = $(target).data "sign"

            @select news_id, sign

        $(".time_separater").on 'click', (e) =>
            selected_time = new Date($(e.currentTarget).data "time")

            $("[data-time]").each (k, v) =>
                if selected_time <= new Date($(v).data "time")
                    news_dom = $(v).prev()
                    news_id = $(news_dom).data "news"
                    sign = $(news_dom).data "sign"

                    @select news_id, sign, true

            @show_selected()

    result_scroll_trigger: () =>
        $(window).scroll ->
            ofs = $(window).scrollTop()
            $("[data-role='result']").css
                "margin-top": "#{ofs}px"

    select: (news_id, sign, bulk = false) =>
        unless @selected[news_id] is undefined
            delete @selected[news_id]
            $("[data-news='#{news_id}']").css
                'box-shadow': '0px 0px 0px 0px orange'
        else
            @selected[news_id] = sign
            $("[data-news='#{news_id}']").css
                'box-shadow': '0px 0px 0px 3px orange'

        @show_selected() unless bulk

    show_selected: () =>
        $("[data-role='result']").html ""

        label = $("<span>").attr "class", "label label-warning"
            .html "selected"
        label = $("<p>").append label
        $("[data-role='result']").append label

        sign_patterns = ["label-danger", "label-info", "label-success"]
        @selected.forEach (v, k) =>
            label = $("<span>").attr "class", "label #{sign_patterns[(v + 1)]}"
                .html k
            $("[data-role='result']").append label
            $("[data-role='result']").append ' '
