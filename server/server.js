const http = require('http');
const server = http.createServer();
const io = require("socket.io")(server);

io.on('connection', (socket) => {
    console.log("Client connected");

    socket.on('message', (msg) => {
        console.log(msg);
      io.emit('response', "'" +  msg + "' mesajınız alındı.");
    });

    socket.on('disconnect', () => {
        console.log("Client disconnected");
    });
  });

server.listen(3000, () => {
  console.log('listening on *:3000');
});