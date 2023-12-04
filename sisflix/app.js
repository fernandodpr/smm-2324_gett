const express = require('express');
const app = express();
const https = require('https');
const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');

const publicPath = path.join(__dirname, 'public');
const viewsPath = path.join(__dirname, 'views');

// Configuración para HTTPS

const privateKey = fs.readFileSync("/ssl/server.key", 'utf8');
const certificate = fs.readFileSync("/ssl/server.cert", 'utf8');
const credentials = { key: privateKey, cert: certificate };

// Crea el servidor HTTPS
const httpsServer = https.createServer(credentials, app);

//app.use(express.static(publicPath));
app.use('/static', express.static(path.join(__dirname, 'node_modules')));
app.use(express.json());
app.set('view engine', 'ejs');
mongoose.connect('mongodb://mongo:27017/videos');



const videoSchema = new mongoose.Schema({
  titulo: String,
  src: String,
  _id: mongoose.Schema.Types.ObjectId,
  key: String,
  keyid: String
  //definimos la varialbles que tiene el video
});

const Video = mongoose.model('Video', videoSchema);

// aqui hacemos el get de los videos
app.get('/', async (req, res) => {
  try {
    const videos = await Video.find(); //obtenemos la lista de videos de mongo

    res.render('index', { videos }); //para renderizar la pagina index.ejs
  } catch (error) {
    console.error('Error al obtener la lista de videos:', error);
    res.status(500).send('Error interno del servidor');
  }
});


// Página para el reproductor de video con parámetro (id del video correspondiente) en la URL (opcional)
app.get('/video/:id?', async (req, res) => {
  const videoId = req.params.id;
  let video;
  try{
    video = await Video.findById(req.params.id);
    
    res.render('video', { video });
  }catch(error){
    res.status(500).send(error);
  }
  
 
});

app.get('/api/video/:id', async (req, res) => {
  try {
    // Si estás usando el _id generado automáticamente por Mongoose
    const video = await Video.findById(req.params.id);

    // Si estás usando tu propio campo 'id'
    // const video = await Video.findOne({ id: req.params.id });

    if (!video) {
      return res.status(404).send('Video no encontrado');
    }
    res.send(video);
  } catch (error) {
    res.status(500).send(error);
  }
});

app.post('/api/video', async (req, res) => {
  try {
    const nuevoVideo = new Video({
      _id: new mongoose.Types.ObjectId(),
      ...req.body
    });
    await nuevoVideo.save();
    res.status(201).json({ message: 'Video creado exitosamente', video: nuevoVideo });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


const httpsPort = 443;


httpsServer.listen(httpsPort, () => {
  console.log(`Servidor HTTPS en https://localhost:${httpsPort}`);
});

