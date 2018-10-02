function WebSocketClient(socket) {
    function send(message) {
        if (message.constructor.name === 'Command')
            message = new Message([message]);

        socket.send(message.stringify());
    }

    function cmd(name, args) {
        return new Command(name, args)
    }

    this.readScheme = function () {
        let args = {
            database: $('#databases-list .active').text(),
            measurement: $('#measurements-list .active').text(),
            tag: $('#tags-list .active').text()
        };

        send(cmd('read_scheme', args));
    };

    this.readData = function (args) {
        send(cmd('read_data', args))
    };

    this.readMetadata = function (args) {
        send(cmd('read_metadata', args))
    };

    this.readInfo = function () {
        send(cmd('read_info'));
    };

    this.getReductionTypes = function () {
        send(cmd('reduction_types'));
    };
}

$(window).on('load', function () {
    let socket = new WebSocket('ws://' + location.hostname + ':' + location.port);

    socket.onopen = function () {
        PVClient.readInfo();
    };

    socket.onclose = function () {
        logMessage({ type: 'error', message: 'Connection lost. Try reload.'});
        disconnectionAlert();
    };

    socket.onmessage = function (messageEvent) {
        let message = JSON.parse(messageEvent.data);
        interpretMessage(message);
    };

    PVClient = new WebSocketClient(socket);
});