-- Library for communicating with a FusionControl server
-- Copyright 2016 TOWER Devs, all rights reserved.

-- Load additional libraries
os.loadAPI("/libraries/tls")

function command(listenport, transmitport, password, functionCommand, publicKey, privateKey, cipher, logfile, modem)
  -- Close all connections, for integrity
  modem.closeAll()
  -- Open ControlPort listenport for listening
  modem.open(listenport)
     -- Send public key to server
     modem.transmit(transmitport, listenport, publicKey)
     logfile.writeLine("Sent our public key packet to the server\n")
     logfile.flush()
     event, modemSide, senderChannel, replyChannel, serverPublicKey, senderDistance = os.pullEvent("modem_message")

     -- Wait for command reply and instruction
     commandReply = tls.recieveSecure(privateKey, cipher)
      -- Is the command reply AUTHENTICATE?
      if commandReply == "authenticate" then
      logfile.writeLine("Got reply: AUTHENTICATE\n")
      logfile.flush()
      -- Send back the authentication passkey
      tls.sendSecure(transmitport, listenport, password, serverPublicKey, cipher, modem)
      logfile.writeLine("Sending authentication packet to server\n")
      logfile.flush()
      -- Wait for authentication adknowlegement
      authReply = tls.recieveSecure(privateKey, cipher)
       if authReply == "authsuccess" then
       logfile.writeLine("Got reply: AUTHSUCCESS\n")
       logfile.writeLine("Requesting data from server\n")
       logfile.flush()
        -- Request Alarm Status from server
        tls.sendSecure(transmitport, listenport, functionCommand, serverPublicKey, cipher, modem)
        returnData = tls.recieveSecure(privateKey, cipher)
        return returnData;
       elseif authReply == "authfail" then
        -- Server gave invalid key message
        logfile.writeLine("Got reply: AUTHFAIL\n")
        logfile.writeLine("Redstone server denied our key!\n")
        logfile.flush()
       else
        -- Server gave invalid response to key adknowlegement
        logfile.writeLine("Got invalid parameter from server!\n")
        logfile.writeLine("Parameter:" .. authReply)
        logfile.flush()
       end
      else
      -- Server gave invalid response to command reply
      logfile.writeLine("Got invalid parameter from server!\n")
      logfile.writeLine("Parameter:" .. commandReply)
      logfile.flush()
     end
     -- Finish up communication with Redstone Server
     modem.closeAll()
     term.redirect(rmon.restoreTo)
     logfile.writeLine("Finished communication with server\n")
     logfile.flush()
     term.redirect(rmon)
end
