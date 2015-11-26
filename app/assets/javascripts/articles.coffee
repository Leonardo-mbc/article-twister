class @Picker
    constructor: (api_url) ->
        @endpoint = api_url
        @select_cells = []

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
                tr_tag = $("<tr>")

                tr_tag.append $("<td>").append @check_cell { topic_id: item.id }
                tr_tag.append $("<td>").append item.id
                tr_tag.append $("<td>").append item.title
                tr_tag.append $("<td>").append item.quant

                tr_tags.push tr_tag

        if items.news
            $.each items.news, (key, item) =>
                tr_tag = $("<tr>")

                tr_tag.append $("<td>").append @check_cell { news_id: item.id }
                tr_tag.append $("<td>").append item.id
                tr_tag.append $("<td>").append item.title
                tr_tag.append $("<td>").append item.body
                tr_tag.append $("<td>").append item.url

                tr_tags.push tr_tag

        $(".cells").append tr_tags

    check_cell: (id) =>
        input = $("<input>")

        $(input).attr "type", "checkbox"
        $(input).on "click", =>
            @select_cells.push id

        input
