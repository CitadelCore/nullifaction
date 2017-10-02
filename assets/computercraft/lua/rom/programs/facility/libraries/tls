function sendSecure(sendport, recvport, message, cryptkey, cipher, modem)
  message = textutils.serialize(message)
  message = cipher.encrypt(message, cryptkey)
  modem.transmit(sendport, recvport, message)
end

function recieveSecure(cryptkey, cipher)
  event, modemSide, senderChannel, replyChannel, commandData, senderDistance = os.pullEvent("modem_message")
  commandData = cipher.decrypt(commandData, cryptkey)
  commandData = textutils.unserialize(commandData)
  return commandData
end

function sendSecureRednet(senderID, message, cryptkey, cipher)
  message = textutils.serialize(message)
  message = cipher.encrypt(message, cryptkey)
  rednet.send(senderID, message, "authsec")
end

function recieveSecureRednet(cryptkey, cipher)
  senderID, commandData, protocol = rednet.receive("authsec")
  commandData = cipher.decrypt(commandData, cryptkey)
  commandData = textutils.unserialize(commandData)
  return senderID, commandData
end
