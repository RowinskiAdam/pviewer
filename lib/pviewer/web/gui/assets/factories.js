function Command(name, args){
    this.name = name;
    this.arguments = removeEmptyKeys(args);

    this.addArg = function(arg, value){
        arguments[arg] = value
    }
}

function Message(commands){
    this.commands = commands;

    this.addCommand = function(command){
      commands.push(command);
      return this;
    };

    this.stringify = function(){
        return JSON.stringify({"commands": commands});
    }
}