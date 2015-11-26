class @Picker
    constructor: (api_url) ->
        @endpoint = api_url
        @select_cells = []
        @check_icon = @make_icon_check()

    fetch: (params) ->
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
                @put data

    put: (items) ->
        tr_tags = []

        if items.topics
            $.each items.topics, (key, item) =>
                id =  { topic_id: item.id }

                tr_tag = $("<tr>")
                $(tr_tag).attr 'data-id', item.id
                $(tr_tag).on "click", (e) =>
                    @select e, item.id

                tr_tag.append $("<td>").append @check_icon
                tr_tag.append $("<td>").append item.id
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

        $(".cells").append tr_tags

    select: (e, id) =>
        if id in @select_cells
            @select_cells.splice @select_cells.indexOf(id), 1
            $(e.currentTarget).find("i").css "opacity", 0
        else
            @select_cells.push id
            $(e.currentTarget).find("i").css "opacity", 1

    make_icon_check: () =>
        check = $("<i>")
        $(check).attr "class", "fa fa-check-circle"
        $(check).css "opacity", 0

        icon = $(check).get(0).outerHTML

        icon
