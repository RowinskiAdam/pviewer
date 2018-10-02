function interpretMessage(message) {

    this.display_info = function (args) {
        let data = args.data;
        let destination = $('#information-tab-body > .row');

        $.each(data, function (key, value) {
            let column = $('<div class="col row align-items-start"></div>');

            column.append('<div class="title col-sm-12">' + key.toUpperCase() + ':</div>');
            $.each(value, function (key, value) {
                column.append('<div class="col col-sm-6">' + keyToName(key) + ':</div>' +
                    '<div class="col">' + value + '</div>')
            });
            destination.append(column)
        });
    };

    this.display_scheme = function (args) {
        unblockDatabaseMenu();

        if (Object.keys(args.data).length === 0) return;

        let name = SchemeLists[Object.keys(args.details).length];
        let list = $('#' + name + '-list');
        let selected = $('#' + list.data('parent') + '-list > .active').data('vals');

        list.parent().fadeIn();
        $.each(args.data, function (i, value) {
            let element = $('<a href="#" class="list-group-item list-group-item-action">' + value + '</a>');
            if (selected !== undefined && $.inArray(value, selected) >= 0)
                element.addClass('selected');

            list.append(element)
        });
    };

    this.display_data = function (args) {
        unblockDatabaseMenu();
        let data = args.data;

        if (jQuery.isEmptyObject(data)) {
            if (Chart.exists()) {
                //Chart.destroy();
                //PVClient.remove_series();
            }
            logMessage({type: 'info', message: 'No data to display.'});
        }
        else {
            Chart.updateOptions();
            Chart.drawChart();
            if (data) Chart.addData(data);
        }
    };


    this.log = function (args) {
        logMessage(args);
    };

    this.reduction_types = function (args) {
        $.each(args.methods, function (i, value) {
            $('#reduce-type').append('<option>'+value+'</option>')
        })
    };

    this.display_metadata = function (args) {
        let metadata = args.data;

        if (metadata !== undefined) {
            let element = $('#measurements-list .list-group-item:contains(' + args.measurement + ')');
            element.data('toggle', 'popover');
            element.popover({
                content: metadata,
                boundary: 'window',
                placement: 'left',
                trigger: "manual",
                viewport: ".container"});
        }
    };

    message.commands.forEach(function (command_obj) {
        let command = command_obj.command;
        let args = command_obj.arguments;

        if (jQuery.isFunction(this[command]))
            this[command](args);
    });
}