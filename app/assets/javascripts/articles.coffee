class @Picker
    constructor: (api_url) ->
        @endpoint = api_url
        @select_cells = []
        @check_icon = @make_icon_check()
        @topic_page = 1

        @tab_enable()
        @pager_enable()
        @importer_enable()

    fetch: (params, target) ->
        options = {
            topic_id: null,
            news_id: null,
        }
        if params
            (options[k] = v for k, v of params)

        $.ajax
            type: 'GET'
            url: "#{@endpoint}/api/v1/"
            dataType: 'json'
            data: options

            success: (data) =>
                @put data, target

    put: (items, target) =>
        tr_tags = []
        table = $(".#{target}-cells")

        if items.topics
            $.each items.topics, (key, item) =>
                id =  { topic_id: item.id }

                tr_tag = $("<tr>")
                $(tr_tag).attr 'data-id', item.id
                $(tr_tag).on "click", (e) =>
                    @select e, item.id

                tr_tag.append $("<td>").append @check_icon
                tr_tag.append $("<td>").append @link_to 'article_list', item.id
                tr_tag.append $("<td>").append item.title
                tr_tag.append $("<td>").append item.quant

                tr_tags.push tr_tag

        if items.news
            $.each items.news, (key, item) =>
                id = { news_id: item.id }

                tr_tag = $("<tr>")
                $(tr_tag).attr 'data-id', item.id
                $(tr_tag).on "click", (e) =>
                    @select e, item.id

                tr_tag.append $("<td>").append @check_icon
                tr_tag.append $("<td>").append item.id
                tr_tag.append $("<td>").append item.title
                tr_tag.append $("<td>").append item.body
                tr_tag.append $("<td>").append item.url

                tr_tags.push tr_tag

        if target is 'items'
            tr_tags = []

            $.each @select_cells, (key, id) ->
                tr_tag = $("<tr>")
                tr_tag.append $("<td>").append id
                tr_tag.append $("<td>").append 'トピック群' if typeof id is 'string'
                tr_tag.append $("<td>").append '単一ニュース' if typeof id is 'number'
                tr_tags.push tr_tag

            $(table).html tr_tags

        else
            $("[data-tab]").removeClass 'active'
            $("[data-tab='#{target}']").addClass 'active'

            $("table").hide()

            $(table).html tr_tags
            $(table).show()

    select: (e, id) =>
        if e.currentTarget
            tr = e.currentTarget
        else
            tr = e

        if id in @select_cells
            @select_cells.splice @select_cells.indexOf(id), 1
            $(tr).find("i").css "opacity", 0
        else
            @select_cells.push id
            $(tr).find("i").css "opacity", 1

        @put @select_cells, 'items'

    link_to: (which, id) =>
        a_tag = $("<a>")

        if which is 'article_list'
            $(a_tag).html id
            $(a_tag).css { 'cursor': 'pointer' }
            $(a_tag).on 'click', =>
                @fetch { topic_id: id }, 'article'

        if which is 'topic_list'
            $(a_tag).attr 'class', "btn btn-default"
            $(a_tag).on 'click', =>
                @fetch {}, 'topic'

        a_tag

    paging: (num) ->
        $("[data-role='page_num']").removeClass "active"
        button = $("[data-role='page_num']").get(num - 1)
        $(button).addClass "active"

        @topic_page = num
        @fetch { page: num }, 'topic'

    erase: (target) ->
        $(".#{target}-cells").html ""

    tab_enable: =>
        $(".import").hide()
        $(".items-cells").hide()

        $("[data-tab]").on 'click', (e) =>
            target = $(e.currentTarget).data "tab"

            $("table").hide()
            $(".#{target}-cells").show()

            if target is 'topic'
                $(".pagination").show()
            else
                $(".pagination").hide()

            if target is 'items'
                $(".import").show()
            else
                $(".import").hide()

    pager_enable: =>
        $("[data-role='page_num']").on 'click', (e) =>
            page_num = parseInt $(e.currentTarget).text()
            @paging page_num

        $("[data-role='page_prev']").on 'click', (e) =>
            page_num = @topic_page - 1
            @paging page_num

        $("[data-role='page_next']").on 'click', (e) =>
            page_num = @topic_page + 1
            @paging page_num

    importer_enable: ->
        $("[data-import]").on 'click', (e) =>
            $("[data-import]").addClass 'disabled'
            method = $(e.currentTarget).data "import"

            selected = { topics: [], news: [] }
            if method is 'news'
                selected.news = @select_cells.filter (id) ->
                    typeof id is 'number'
            else
                selected.topics = @select_cells.filter (id) ->
                    typeof id is 'string'
                selected.news = @select_cells.filter (id) ->
                    typeof id is 'number'

            console.log "ダウンロード中..."
            $.ajax
                type: 'GET'
                url: "import"
                data:
                    selected: selected

                success: (data) ->
                    $("[data-import]").removeClass 'disabled'

                error: (data) ->
                    $("[data-import]").removeClass 'disabled'

        $("[data-combine]").on 'click', (e) =>
            name = $("#profile_name").val()
            $("#profile_name").parent().removeClass("has-error")

            if name
                $("[data-combine]").addClass 'disabled'

                selected_ids = @select_cells.filter (id) ->
                    typeof id is 'number'

                $.ajax
                    type: 'GET'
                    url: "combine"
                    data:
                        selected: selected_ids
                        name: name

                    success: (data) ->
                        $("[data-combine]").removeClass 'disabled'

                    error: (data) ->
                        $("[data-combine]").removeClass 'disabled'
            else
                $("#profile_name").parent().addClass("has-error")



    make_icon_check: () =>
        check = $("<i>")
        $(check).attr "class", "fa fa-check-circle"
        $(check).css "opacity", 0

        icon = $(check).get(0).outerHTML

        icon
