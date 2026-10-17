trigger dataFormat on Contact (before insert, before update) {
    dataFormatHandler.changeDataFormat(Trigger.new);
}