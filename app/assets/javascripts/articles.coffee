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

class @Plotter
    constructor: (width, height, picker) ->
        @width = width
        @height = height
        @picker = picker

        @axis_label = { X: null, Y: null }
        @div_num = 4

        @stage = d3.select ".stage"
            .append 'svg'
        @dataset = []
        @user_data = []

        @stage.attr 'width', @width
            .attr 'height', @height

        @padding = 50
        @xScale = d3.scale.linear()
            .domain [-1, 1]
            .range [@padding, @width - @padding]
        @yScale = d3.scale.linear()
            .domain [-1, 1]
            .range [@height - @padding, @padding]

        @append_axis_label()

    cluster_slider_trigger: () =>
        $("[data-role='divider']").on
            'input': (e) =>
                $("#divider").html $(e.currentTarget).val()

            'change': (e) =>
                @div_num = $(e.currentTarget).val()
                @clustering()

        if @axis_label.X is @axis_label.Y and @axis_label.X is null
            $("[data-role='divider']").get(0).disabled = true;

    tuner_scroll_trigger: () =>
        $(window).scroll ->
            ofs = $(window).scrollTop()
            $("[data-role='tuner']").css
                "margin-top": "#{ofs}px"

    append_axis_label: () =>
        d3.selectAll("g").remove()

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

    change_divide: (div_num) =>
        @div_num = div_num

    change_axis: (axis, name) ->
        @axis_label[axis] = name
        $("[data-role='divider']").get(0).disabled = false;

        $("[data-title='#{axis}']").html name
            .parent().removeClass('open');
        $("[data-label='#{axis}']").html name

    clear_axis: (axis) =>
        @axis_label[axis] = null
        @dataset.forEach (data, news_id) =>
            if axis is 'X'
                @dataset[news_id].x = 0.5
                @user_data.x = 0.5
            if axis is 'Y'
                @dataset[news_id].y = 0.5
                @user_data.y = 0.5

            $("[data-title='#{axis}']").html "#{axis}軸へのマッピング"

        if @axis_label.X is @axis_label.Y and @axis_label.X is null
            $("[data-role='divider']").get(0).disabled = true;

        @plot()

    mount: (axis, id, value) =>
        switch axis
            when 'x'
                if id is 'user'
                    if @user_data
                        @user_data.x = value
                        @user_data.y = 0.5 unless @user_data.y
                else
                    if @dataset[id]
                        @dataset[id].x = value
                    else
                        @dataset[id] = { x: value, y: 0.5 }
            when 'y'
                if id is 'user'
                    if @user_data
                        @user_data.x = 0.5 unless @user_data.x
                        @user_data.y = value
                    else
                        @user_data = { x: 0.5, y: value }
                else
                    if @dataset[id]
                        @dataset[id].y = value
                    else
                        @dataset[id] = { x: 0.5, y: value }

    plot: () =>
        self = this

        scale = 0.5
        width = @padding * scale
        height = @padding * scale
        @stage.selectAll('image').remove()
        @stage.selectAll('text').remove()

        @scale_update()

        @dataset.forEach (data, news_id) =>
            @stage.append 'image'
                .attr 'id', news_id
                .attr 'x', @xScale(data.x) - width * 0.5
                .attr 'y', @yScale(data.y) - height * 0.5
                .attr 'class', 'document'
                .attr 'width', width
                .attr 'height', height
                .attr 'xlink:href', '/images/document_gray.svg'
                .on 'mouseover', ->
                    self.picker.fetch({ news_id: news_id }, "details")
                    d3.select(this)
                        .attr 'xlink:href', '/images/document_blue.svg'
                .on 'mouseout', ->
                    item = d3.select(this)
                    cluster = item.attr 'cluster'
                    if cluster
                        item.attr 'xlink:href', "/images/document_clusters/#{cluster}.svg"
                    else
                        item.attr 'xlink:href', '/images/document_gray.svg'
                .on 'click', =>
                    console.log "open", news_id

        @stage.append 'image'
            .attr 'x', @xScale(@user_data.x) - width * 0.5
            .attr 'y', @yScale(@user_data.y) - height * 0.5
            .attr 'class', 'document'
            .attr 'width', width
            .attr 'height', height
            .attr 'xlink:href', '/images/user.svg'

        @clustering() unless @axis_label.X is @axis_label.Y and @axis_label.X is null
        @append_axis_label()

    clustering: () =>
        d3.selectAll("text").remove()
        filename = new Date().getTime()

        map = []
        @dataset.forEach (data, news_id) =>
            map.push { news_id: news_id, x: data.x, y: data.y }

        $.ajax
            url: '/articles/clustering'
            type: 'post'
            data:
                map: map
                div: @div_num
                label_quant: 5
                filename: filename

            success: =>
                @recommend filename

        @append_axis_label()

    plot_gravities: (text, x, y) =>
        scale = 0.8
        width = @padding * scale
        height = @padding * scale

        @stage.append 'text'
            .attr 'x', @xScale(x) - width * 0.5
            .attr 'y', @yScale(y) - height * 0.5
            .attr 'original-title', @make_thumbs(text)
            .attr 'class', 'gravity'
            .text text

        $('text').tipsy
            gravity: 's'
            delayOut: 50
            html: true
            trigger: 'focus'

    svg_replace: (id, cluster) =>
        $(".stage").find "image##{id}"
            .attr 'href', "/images/document_clusters/#{cluster}.svg"
            .attr 'cluster', cluster

    cluster_rating: (word, score) =>
        $.ajax
            url: '/users/instant_profile_update'
            type: 'get'
            data:
                word: word
                score: score
            dataType: 'json'

            success: (data) =>
                #if @axis_label.X is "自分のプロファイル"
                #if @axis_label.Y is "自分のプロファイル"

    make_thumbs: (word) =>
        thumbs_up = $("<a>").attr 'href', "JavaScript: plotter.cluster_rating(\"#{word}\", 1)"
            .append $("<i>").attr 'class', 'fa fa-thumbs-up'
            .get(0).outerHTML
        thumbs_down = $("<a>").attr 'href', "JavaScript: plotter.cluster_rating(\"#{word}\", -1)"
            .append $("<i>").attr 'class', 'fa fa-thumbs-down'
            .get(0).outerHTML

        rate_link = "#{thumbs_up} or #{thumbs_down}"

        rate_link

    scale_update:() =>
        ary_x = []
        ary_y = []
        @dataset.map (d) ->
            ary_x.push d.x
            ary_y.push d.y

        min_x = Math.min.apply(null, ary_x) - 0.05
        min_y = Math.min.apply(null, ary_y) - 0.05
        max_x = Math.max.apply(null, ary_x) + 0.05
        max_y = Math.max.apply(null, ary_y) + 0.05

        @xScale = d3.scale.linear()
            .domain [min_x, max_x]
            .range [@padding, @width - @padding]
        @yScale = d3.scale.linear()
            .domain [min_y, max_y]
            .range [@height - @padding, @padding]

    recommend:(filename) =>
        $.ajax
            url: '/articles/recommend'
            type: 'post'
            data:
                filename: filename
                user_x: @user_data.x
                user_y: @user_data.y
                quant: 10

            success: (data) ->
                $("[data-role='recommend']").html data
                rating.rating_enable()


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

    push: (id, sign) ->
        $.ajax
            url: '/articles/push_rate'
            type: 'get'
            data:
                news_id: id
                sign: sign
            dataType: 'json'

            success: (data) ->
                title = $("[data-news='#{id}']").find 'h3'
                re = new RegExp "glyphicon-ok", "i"

                if !title.html().match(re)
                    $(title).prepend '<span class="glyphicon glyphicon-ok" aria-hidden="true"></span> '

                $(".progress-bar").animate
                    width: 100 * data.checked / 50 +"%"
                ,
                    duration: 300

                if 50 <= data.checked
                    make_profile()
