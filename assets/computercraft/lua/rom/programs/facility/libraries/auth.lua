-- Library for communicating with a FusionAuth server
-- Copyright 2016 TOWER Devs, all rights reserved.

-- Load additional libraries
os.loadAPI("/libraries/tls")

function command(destinationhostname, password, functionCommand, publicKey, privateKey, logindata, cipher, logfile)
     rednet.open("right")
     destID = rednet.lookup("authsec", destinationhostname)
     -- Send HELLO message to any listening FusionServer
     rednet.send(destID, publicKey, "authsec")
     logfile.writeLine("Sent our public key packet to the server\n")
     logfile.flush()

     -- Wait for command reply and instruction
     senderID, clientPublicKey, protocol = rednet.receive("authsec")
     senderID, commandReply = tls.recieveSecureRednet(privateKey, cipher)
      -- Is the command reply AUTHENTICATE?
      if commandReply == "authenticate" then
      logfile.writeLine("Got reply: AUTHENTICATE\n")
      logfile.flush()
      -- Send back the authentication passkey
      tls.sendSecureRednet(destID, password, clientPublicKey, cipher)
      logfile.writeLine("Sending authentication packet to server\n")
      logfile.flush()
      -- Wait for authentication adknowlegement
      senderID, authReply = tls.recieveSecureRednet(privateKey, cipher)
       if authReply == "authsuccess" then
       logfile.writeLine("Got reply: AUTHSUCCESS\n")
       logfile.writeLine("Requesting data from server\n")
       logfile.flush()
        -- Request auth from server
        tls.sendSecureRednet(destID, functionCommand, clientPublicKey, cipher)
        senderID, returnData = tls.recieveSecureRednet(privateKey, cipher)
        if returnData == "sendbiodata" then
          logfile.writeLine("Got reply: SENDBIODATA\n")
          logfile.writeLine("Sending data\n")
          logfile.flush()
          tls.sendSecureRednet(destID, logindata, clientPublicKey, cipher)
          senderID, returnData = tls.recieveSecureRednet(privateKey, cipher)
          logfile.writeLine("Got reply from server")
          logfile.flush()
          return returnData
        elseif returnData == "sendkeypaddata" then
          logfile.writeLine("Got reply: SENDKEYPADDATA\n")
          logfile.writeLine("Sending data\n")
          logfile.flush()
          tls.sendSecureRednet(destID, logindata, clientPublicKey, cipher)
          senderID, returnData = tls.recieveSecureRednet(privateKey, cipher)
          logfile.writeLine("Got reply")
          logfile.flush()
          return returnData
        elseif returnData == "sendrfiddata" then
          logfile.writeLine("Got reply")
          logfile.writeLine("Sending data\n")
          logfile.flush()
          tls.sendSecureRednet(destID, logindata, clientPublicKey, cipher)
          senderID, returnData = tls.recieveSecureRednet(privateKey, cipher)
          logfile.writeLine("Got reply")
          logfile.flush()
          return returnData
        elseif returnData == "sendmagstripedata" then
          logfile.writeLine("Got reply: SENDMAGSTRIPEDATA\n")
          logfile.writeLine("Sending data\n")
          logfile.flush()
          tls.sendSecureRednet(destID, logindata, clientPublicKey, cipher)
          senderID, returnData = tls.recieveSecureRednet(privateKey, cipher)
          logfile.writeLine("Got reply")
          logfile.flush()
          return returnData
        else
        return returnData
        end
       elseif authReply == "authfail" then
        -- Server gave invalid key message
        logfile.writeLine("Got reply: AUTHFAIL\n")
        logfile.writeLine("Authentication server denied our key!\n")
        logfile.flush()
       else
        -- Server gave invalid response to key adknowlegement
        logfile.writeLine("Got invalid parameter from authentication server!\n")
        logfile.flush()
       end
      else
      -- Server gave invalid response to command reply
      logfile.writeLine("Got invalid parameter from authentication server!\n")
      logfile.flush()
     end
     -- Finish up communication with Auth Server
     rednet.close("top")
     term.redirect(rmon.restoreTo)
     logfile.writeLine("Finished communication with server\n")
     logfile.flush()
     term.redirect(rmon)
end
