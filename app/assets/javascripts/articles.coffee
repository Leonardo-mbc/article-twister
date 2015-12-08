class @Picker
    constructor: (api_url) ->
        @endpoint = api_url
        @select_cells = []
        @check_icon = @make_icon_check()
        @topic_page = 1
        @requests = []

        @tab_enable()
        @pager_enable()
        @importer_enable()

    fetch: (params, target) =>
        @clear_requests()

        options = {
            topic_id: null,
            news_id: null,
        }
        if params
            (options[k] = v for k, v of params)

        @requests.push $.ajax
            type: 'GET'
            url: "#{@endpoint}/api/v1/"
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

        if items.topics
            $.each items.topics, (key, item) =>
                id =  { topic_id: item.id }

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

            if target is 'topic' or target is 'imported_news'
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

class @Plotter
    constructor: (width, height, picker) ->
        @width = width
        @height = height
        @picker = picker

        @stage = d3.select ".stage"
            .append 'svg'
        @dataset = []

        @stage.attr 'width', @width
            .attr 'height', @height

        @padding = 30
        @xScale = d3.scale.linear()
            .domain [0, 1]
            .range [@padding, @width - @padding]
        @yScale = d3.scale.linear()
            .domain [0, 1]
            .range [@height - @padding, @padding]

        xAxis = d3.svg.axis()
            .scale @xScale
            .orient 'bottom'
        yAxis = d3.svg.axis()
            .scale @yScale
            .orient 'left'
        @stage.append 'g'
            .attr 'class', 'axis_x'
            .attr "transform", "translate(0, " + (@height - @padding) + ")"
            .call xAxis
        @stage.append 'g'
            .attr 'class', 'axis_y'
            .attr "transform", "translate(" + @padding + ", 0)"
            .call yAxis

    change_axis: (axis, name) ->
        $("[data-title='#{axis}']").html name
        $("[data-label='#{axis}']").html name

    clear_axis: (axis) =>
        @dataset.forEach (data, news_id) =>
            @dataset[news_id].x = 0.5 if axis is 'X'
            @dataset[news_id].y = 0.5 if axis is 'Y'
            $("[data-title='#{axis}']").html "#{axis}軸へのマッピング"

        @plot()

    mount: (axis, id, value) =>
        switch axis
            when 'x'
                if @dataset[id]
                    @dataset[id].x = value
                else
                    @dataset[id] = { x: value, y: 0.5 }
            when 'y'
                if @dataset[id]
                    @dataset[id].y = value
                else
                    @dataset[id] = { x: 0.5, y: value }

    plot: () =>
        self = this

        scale = 0.8
        width = @padding * scale
        height = @padding * scale
        @stage.selectAll('image').remove()

        @dataset.forEach (data, news_id) =>
            @stage.append 'image'
                .attr 'x', @xScale(data.x) - width * 0.5
                .attr 'y', @yScale(data.y) - height * 0.5
                .attr 'class', 'document'
                .attr 'width', width
                .attr 'height', height
                .attr 'xlink:href', '/assets/document_gray.svg'
                .on 'mouseover', ->
                    self.picker.fetch({ news_id: news_id }, "details")
                    d3.select(this)
                        .attr 'xlink:href', '/assets/document_blue.svg'
                .on 'mouseout',  ->
                    d3.select(this)
                        .attr 'xlink:href', '/assets/document_gray.svg'
                .on 'click', =>
                    console.log "open", news_id
