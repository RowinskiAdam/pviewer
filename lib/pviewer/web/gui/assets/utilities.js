function removeEmptyKeys(obj) {
    if (obj != null)
        Object.keys(obj).forEach((key) => (obj[key] == null || obj[key] === "") && delete obj[key]);

    return obj;
}

function localTimeNow() {
    let date = new Date();

    let hours = date.getHours();
    let days = hours < 2 ? date.getUTCDate() + 1 : date.getUTCDate();
    days = days < 10 ? '0' + days : days;

    let time = date.toLocaleTimeString();
    return date.toJSON().slice(0, 8) + days + 'T' + time
}

function keyToName(string){
    string = string.capitalize();

    return _ToSpace(string);
}

function _ToSpace(string){
    return string.replace(/_/g, ' ')
}

Object.defineProperty(String.prototype, 'capitalize', {
    value() {
        return `${this[0].toUpperCase()}${this.slice(1)}`
    }
});

