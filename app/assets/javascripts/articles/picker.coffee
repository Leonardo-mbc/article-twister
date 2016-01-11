class @Picker
    constructor: (api_url) ->
        @endpoint = api_url
        @select_cells = []
        @check_icon = @make_icon_check()
        @page = { topic: 1, recently: 1 }
        @visible_tab = 'topic'
        @requests = []

        @tab_enable()
        @pager_enable()
        @importer_enable()

    fetch: (params, target) =>
        @clear_requests()

        options = {
            topic_id: null,
            news_id: null,
            action: '',
            dispatch: ->
                return
        }
        if params
            (options[k] = v for k, v of params)
            # options.dispatch関数はここで実行される

        @requests.push $.ajax
            type: 'GET'
            url: "#{@endpoint}/api/v1/#{options.action}"
            dataType: 'json'
            data: options

            success: (data) =>
                @put data, target, true

    clear_requests: =>
        @requests.forEach (req) =>
            req.abort()
            @requests.splice req, 1

    put: (items, target, move) =>
        tr_tags = []
        table = $(".#{target}-cells")

        tr_tags.push @make_select_all()

        if items.topics
            $.each items.topics, (key, item) =>
                id = { topic_id: item.id }

                tr_tag = $("<tr>")
                $(tr_tag).attr 'data-id', item.id

                checker = $("<td class='checker'>").append @check_icon
                    .on "click", (e) =>
                        @select e, item.id
                tr_tag.append checker
                tr_tag.append $("<td>").append @link_to 'article_list', item.id
                tr_tag.append $("<td>").append item.title
                tr_tag.append $("<td>").append item.quant
                tr_tag.append $("<td>").append item.updated_at

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
                tr_tag.append $("<td>").append item.body unless target is "recently"
                tr_tag.append $("<td>").append item.url unless target is "recently"
                tr_tag.append $("<td>").append item.updated_at

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
        if target is 'details'
            $(".details").html ""
            $.each items.news, (key, item) =>
                p_tag = $('<p>').html item.title
                small_tag = $('<small>').html item.source

                $(".details").append p_tag, small_tag
        else
            if move
                $("[data-tab]").removeClass 'active'
                $("[data-tab='#{target}']").addClass 'active'

                $("table").hide()
                $(table).show()

            $(table).html tr_tags

    select: (e, id, move = false) =>
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

        @put @select_cells, 'items', move

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

    paging: (num) =>
        $("[data-role='page_num']").removeClass "active"
        button = $("[data-role='page_num']").get(num - 1)
        $(button).addClass "active"

        @page[@visible_tab] = num

        action = ''
        action = "recently.php" if @visible_tab is 'recently'
        @fetch { page: num, action: action }, @visible_tab

    erase: (target) ->
        $(".#{target}-cells").html ""

    tab_enable: =>
        $(".import").hide()
        $(".recently-cells").hide()
        $(".article-cells").hide()
        $(".items-cells").hide()

        $("[data-tab]").on 'click', (e) =>
            target = $(e.currentTarget).data "tab"
            @visible_tab = target

            $("table").hide()
            $(".#{target}-cells").show()

            if target is 'topic' or target is 'recently' or target is 'imported_news'
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
            page_num = @page[@visible_tab] - 1
            @paging page_num

        $("[data-role='page_next']").on 'click', (e) =>
            page_num = @page[@visible_tab] + 1
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

    make_select_all: () =>
        tr_tag = $("<tr>")
        td_tag = $("<td>").attr 'colspan', 6
        a_tag = $("<a>").attr 'class', 'btn btn-link'
            .attr 'data-select', 'uncheck'
            .append $("<i>").attr 'class', 'fa fa-square-o'
            .append " すべて選択"
            .on 'click', (e) =>
                sign = $(e.currentTarget).data 'select'
                if sign is 'check'
                    $("tr:visible[data-id]").each (k, v) =>
                        data_id = $(v).data('id')
                        @select v, data_id

                    $(e.currentTarget).data 'select', 'uncheck'
                    $(e.currentTarget).html $("<i>").attr 'class', 'fa fa-square-o'
                        .append " すべて選択"
                if sign is 'uncheck'
                    $("tr:visible[data-id]").each (k, v) =>
                        data_id = $(v).data('id')
                        @select v, data_id

                    $(e.currentTarget).data 'select', 'check'
                    $(e.currentTarget).html $("<i>").attr 'class', 'fa fa-check-square-o'
                        .append " すべて選択解除"

        $(tr_tag).append $(td_tag).append a_tag

        tr_tag
