SchemeLists = ['databases', 'measurements', 'tags', 'tag-vals'];

$(document).ready(function () {

    // Initialize tooltips.
    $('[data-toggle="tooltip"]').tooltip({trigger: "hover"});

    // Database view

    $('#database-tab').on('click', this, function () {
        if ($('#databases-list').children('a').length > 0)
            return;

        blockDatabaseMenu();
        PVClient.getReductionTypes();
        PVClient.readScheme();
    });

    $('#show-hide-scheme').on('click', this, function () {
        let schemeSelectors = $('#scheme-selectors');
        if (schemeSelectors.is(':visible')) {
            schemeSelectors.hide()
        } else {
            schemeSelectors.show();
        }
    });

    $('#database-tab-body .list-group').on('click', 'a', function () {
        if ($(this).parent().hasClass('select-one'))
            selectOne($(this));
        else
            selectMultiple($(this));
    });

    $('.scheme-group').on('keyup', '.search', function () {
        let current_query = $(this).val();
        let listElement = $(this).siblings('.list-group').children('a');

        if (current_query !== "") {
            listElement.hide();
            listElement.each(function () {
                let current_keyword = $(this).text();
                if (current_keyword.indexOf(current_query) >= 0) {
                    $(this).show();
                }
            });
        } else {
            listElement.show();
        }
    });

    $('#measurements-list').on('mouseover', '.list-group-item', function () {
        if ($(this).data('toggle') === undefined) {
            let args = {
                database: $('#databases-list .active').text(),
                measurement: $(this).text()
            };

            PVClient.readMetadata(args);
            $(this).data('toggle', 'popover');
        }
    }).on('blur', '.list-group-item', function () {
            $(this).popover('hide')
    });

    $('#fetch-data').on('click', this, function () {
        fetchData();
    });

    // Chart options view

    fillCachedOptions();

    $('#save-options').on('click', this, function () {
        saveChartOptions($(this));
    });

    $('form[name=chartType]').on('change', 'input', function () {
        $(this).parent().attr('value', ($(this).val()))
    });

    $('input[type=number]').on('focusout', this, function () {
        if ($(this).val() < parseInt($(this).attr('min')) && $(this).val() !== 0)
            $(this).val($(this).attr('min'))
    });

});

function disconnectionAlert() {
    $('#caution-offline').removeClass('d-none');
}

function blockDatabaseMenu() {
    $("#database-tab-body").addClass("disabled-button");
}

function unblockDatabaseMenu() {
    $("#database-tab-body").removeClass("disabled-button");
}

// Database view functions

function selectOne(element) {
    clearDependent(element.parent());

    if (element.hasClass('active')) {
        element.removeClass('active');
        element.popover('hide');
        return;
    }

    element.siblings().removeClass('active');
    element.addClass('active');
    element.popover('show');
    blockDatabaseMenu();
    PVClient.readScheme();
}

function clearDependent(element) {
    $.each(element.data('dependents'), function (i, value) {
        let dependent = $('#' + value + '-list');
        dependent.html('');
        dependent.parent().hide();
    })
}

function selectMultiple(element) {
    let isTagValsList = element.parent('div#tag-vals-list').length > 0;

    clearDependent(element.parent());

    if (element.hasClass('active') || (element.hasClass('selected') && isTagValsList)) {
        removeTagVals(element);
        element.removeClass('active').removeClass('selected');
        return;
    }

    element.addClass('active').addClass('selected');

    let lastActive = element.siblings('.active').removeClass('active');

    if (isTagValsList)
        addTagVals(element);
    else {
        blockDatabaseMenu();
        PVClient.readScheme();
    }

    if (!isTagValsList && (lastActive.data('vals') === undefined || lastActive.data('vals').length < 1))
        lastActive.removeClass('selected');
    else if (isTagValsList) {
        lastActive.addClass('selected');
        element.addClass('selected').removeClass('active');
    }

}

function removeTagVals(element) {
    if (element.parent('div#tags-list').length > 0) {
        element.data('vals', []);
    } else {
        let tag = $('#tags-list').children('.active');
        let index = tag.data('vals').indexOf(element.text());
        let values = tag.data('vals').splice(index, 1);
    }
}

function addTagVals(element) {
    let tag = $('#tags-list').children('.active');
    let value = element.text();
    let values = tag.data('vals') || [];

    values.push(value);
    tag.data('vals', values);
}

function fetchData() {
    let tags = {};

    $.each($('#tags-list > .selected'), function () {
        let values = $(this).data('vals');
        if (values === null || values.length > 0)
            tags[$(this).text()] = $(this).data('vals')
    });

    let args = {
        database: $('#databases-list > .active').text(),
        measurement: $('#measurements-list > .active').text(),
        tags: tags,
        reduce_type: $('#reduce-type').val(),
        time_precision: $('#time-precision :selected').data('symbol'),
        gui_format: $('input:radio[name="view-type"]:checked').data('value')
    };

    let alert = $('#query-options .alert');
    if (args.database === '' || args.measurement === '') {
        $('#query-options .alert > span').text('Database and measurement must be specified.');
        alert.show();
        return;
    }

    alert.hide();

    blockDatabaseMenu();
    PVClient.readData(args);
}

// log view functions

function logMessage(args) {
    if (args.type === 'error')
        args.type = 'danger';
    else
        args.type = 'light';

    let time = '<span class="text-muted timestamp">' + new Date().toLocaleString() + '</span>';
    let element = '<li class="list-group-item  list-group-item-' + args.type + '" role="alert">'
        + time + args.message + '</li>';

    $('#logs-list').append(element);
}

// chat view functions


function fillCachedOptions() {
    let cache = localStorage['PVChart-Options'];

    if (cache) {
        let stored = JSON.parse(cache);

        $('#chart-options').find($('.chart-option')).each(function () {
            if (stored[$(this).attr('name')])
                if ($(this).attr('type') === 'checkbox') {
                    if (stored[$(this).attr('name')] === 'true')
                        $(this).prop("checked", true);
                }
                else if ($(this).attr('name') === 'chartType') {
                    $(this).attr('value', stored[$(this).attr('name')]);
                    $('input[value=' + stored[$(this).attr('name')] + ']').prop("checked", true);
                    Chart.changeType($(this).attr('value'))
                }
                else
                    $(this).val(stored[$(this).attr('name')])
        });

        logMessage({type: 'info', message: 'Chart options loaded from cache.'});
    }

    Chart.updateOptions();
}

function saveChartOptions(element) {
    let toStore = {};

    $('#chart-options').find($('.chart-option')).each(function () {
        if ($(this).attr('type') === 'checkbox') {
            if ($(this).is(':checked'))
                $(this).val('true');
            else
                $(this).val('false');
        }

        toStore[$(this).attr('name')] = $(this).val() || $(this).attr('value')
    });

    localStorage['PVChart-Options'] = JSON.stringify(toStore);

    logMessage({type: 'info', message: 'Chart options changed.'});

    Chart.updateOptions();
    if (Chart.exists()) {
        Chart.changeType(Chart.chartType);
        Chart.relayout();

    }

    element.text('Saved').addClass('btn-success').removeClass('btn-outline-dark');
    setTimeout(function () {
        element.text("Set").addClass('btn-outline-dark').removeClass('btn-success');
    }, 3000);
}