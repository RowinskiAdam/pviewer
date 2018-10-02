Chart = {};
Chart.viewLast = 0;
Chart.maxPoints = 0;

Chart.holderID = 'mainChart';

Chart.data = function () {
    return document.getElementById('mainChart').data;
};

Chart.exists = function () {
    return $('#' + this.holderID).html() !== '';
};

Chart.dataTimePointsNumber = function () {
    return this.data()[0].x.length
};

Chart.drawChart = function () {
    Plotly.newPlot(this.holderID, [], getLayout(), options);
};

Chart.destroy = function () {
    PVClient.remove_series();
    Plotly.purge(this.holderID);
};

Chart.addData = function (data) {
    $.each(data, function (index, value) {
        Chart.addTrace(value)
    });
};

Chart.addTrace = function (data) {
    data = new DataHolder(data);
    let newData = [];

    if (Chart.maxPoints > 0)
        data.time.splice(0, data.time.length - Chart.maxPoints);

    $.each(data.points, function (k, traceData) {
        if (Chart.maxPoints > 0)
            traceData.splice(0, data.points - Chart.maxPoints);

        let trace = {
                x: data.time,
                y: traceData,
                name: data.traces[k],
                type: Chart.chartType,
                mode: Chart.chartMode,
                transforms: Chart.transforms()
            }
        ;
        newData.push(trace);
    });

    Plotly.addTraces('mainChart', newData);
};

Chart.addPointsToChart = function (data) {
    data = new DataHolder(data);

    let update = {
        x: data.timeForEachTrace(data.time),
        y: data.points
    };

    let maxPoints = this.maxPoints;

    if (maxPoints != 0)
        $.each(this.data(), function (i, e) {
                let pointsToRemove = e.x.length - maxPoints;
                if (pointsToRemove > 0) {
                    e.y.splice(0, pointsToRemove);
                    e.x.splice(0, pointsToRemove);
                }
            }
        );


    Plotly.extendTraces(this.holderID, update, data.tracesIDArray);

    if (this.viewLast > 0)
        this.moveTrace();
};

Chart.moveTrace = function () {
    Plotly.relayout(this.holderID, getLayout());
};

Chart.updateOptions = function () {
    let cache = localStorage['PVChart-Options'];

    if (cache) {
        let stored = JSON.parse(cache);

        $.each(stored, function (opt, value) {
            Chart[opt] = value;
        })
    }
};

Chart.relayout = function () {
    if ($('#' + this.holderID).hasClass('js-plotly-plot'))
        Plotly.relayout(this.holderID, getLayout());
};

Chart.changeType = function (name) {
    let type = this[name]();
    $.each(this.data(), function (i, e) {
            e.type = type.type;
            e.mode = type.mode;
        }
    );

    Chart.chartType = type.type;
    Chart.chartMode = type.mode;
    Chart.relayout();
};

Chart.scatter = function () {
    return {
        type: 'scatter',
        mode: 'lines+markers'
    }
};

Chart.dots = function () {
    return {
        type: 'scatter',
        mode: 'markers'
    }
};

Chart.bar = function () {
    return {
        type: 'bar',
        mode: ''
    }
};

Chart.transforms_active = function () {
    return $('input:radio[name="view-type"]:checked').data('value') === 'Summary'
};

Chart.transforms = function () {
    if (this.transforms_active()) {
        return [{
            type: 'aggregate',
            aggregations: [
                {target: 'y', func: 'sum', enabled: true},
            ]
        }]
    } else
        return [];
};


DataHolder = function (data) {
    function parseDate(data) {
        return data.map(function (e) {
            return new Date(e);
        })
    }

    function unpack(data) {
        let array = Array.from({length: data.columns.length}, (v, k) => []);

        $.each(data.values, function (i, e) {
            $.each(e, function (i, ee) {
                array[i].push(ee)
            });
        });

        return array;
    }

    this.timeForEachTrace = function (array) {
        let newArray = [];
        this.points.forEach(function () {
            newArray.push(array.slice())
        });

        return newArray;
    };


    function pointsWithoutTime(points) {
        return points.splice(1, unpacked_data.length);
    }

    function columnsWithoutTime(columns) {
        return columns.splice(1, data.columns.length)
    }

    let unpacked_data = unpack(data);
    let time = unpacked_data[0];

    //if(typeof unpacked_data[0][0] === "string" )
    //time = parseDate(time);

    this.points = pointsWithoutTime(unpacked_data);
    this.time = time;
    this.traces = [$.map(data.tags, function (k, v) {
        return v + ': ' + k
    }).join(', ')];

    this.tracesIDArray = Array.from({length: this.traces.length}, (v, k) => k);
};


getLayout = function () {
    return {
        width: function () {
            let width = parseInt(Chart.width);
            return width > 0 ? width : null
        }(),
        height: function () {
            let height = parseInt(Chart.height);
            return height > 0 ? height : null
        }(),
        showlegend: function () {
            return Chart.showlegend === 'true';
        }(),
        xaxis: {
            rangeselector: function () {

                if (Chart.rangeselector === 'true') {

                    return {
                        buttons: [
                            {
                                count: 2,
                                label: 'minute',
                                step: 'minute',
                                stepmode: 'backward'
                            },
                            {
                                count: 1,
                                label: 'hour',
                                step: 'hour',
                                stepmode: 'backward'
                            },
                            {
                                count: 1,
                                label: 'day',
                                step: 'day',
                                stepmode: 'backward'
                            },
                            {step: 'all'}
                        ]
                    }
                }
            }(),
            rangeslider: function () {
                if (Chart.rangeslider === 'true') return {};
            }(),
            range: function () {
                let difference = parseFloat(Chart.viewLast);

                if (difference > 0) {
                    let time = new Date();
                    let olderTime = time.setMinutes(time.getMinutes() - difference);
                    let futureTime = time.setMinutes(time.getMinutes() + difference);
                    return [olderTime, futureTime]
                }
            }(),
            autotick: true,
            type: '-'
        },
        yaxis:
            {
                autotick: function () {
                    return Chart.ytick === 'true';
                }(),
                type: '-'
            },
        updatemenus: function () {
            if (Chart.transforms_active()){
                return [{
                    x: 1,
                    y: 1.15,
                    yanchor: 'top',
                    active: 1,
                    showactive: true,
                    buttons: [{
                        method: 'restyle',
                        args: ['transforms[0].aggregations[0].func', 'avg'],
                        label: 'Avg'
                    }, {
                        method: 'restyle',
                        args: ['transforms[0].aggregations[0].func', 'sum'],
                        label: 'Sum'
                    }, {
                        method: 'restyle',
                        args: ['transforms[0].aggregations[0].func', 'min'],
                        label: 'Min'
                    }, {
                        method: 'restyle',
                        args: ['transforms[0].aggregations[0].func', 'max'],
                        label: 'Max'
                    }, {
                        method: 'restyle',
                        args: ['transforms[0].aggregations[0].func', 'mode'],
                        label: 'Mode'
                    }, {
                        method: 'restyle',
                        args: ['transforms[0].aggregations[0].func', 'median'],
                        label: 'Median'
                    }, {
                        method: 'restyle',
                        args: ['transforms[0].aggregations[0].func', 'count'],
                        label: 'Count'
                    }, {
                        method: 'restyle',
                        args: ['transforms[0].aggregations[0].func', 'stddev'],
                        label: 'Std.Dev'
                    }]

                }]}
            else return []
        }()
    };
};

options = {
    scrollZoom: true,
    modeBarButtonsToRemove: ['sendDataToCloud', 'zoom2d', 'pan', 'pan2d'],
    displaylogo: false,
    showLink: false
};