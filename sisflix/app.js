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
// Ruta para mostrar el formulario de añadir nuevo video
app.get('/add-video', (req, res) => {
  res.render('add-video'); // Utiliza una plantilla EJS llamada 'add-video'
});

app.post('/api/video', async (req, res) => {
  try {
    const { titulo, src, key, keyid } = req.body;
    const nuevoVideo = new Video({
      _id: new mongoose.Types.ObjectId(),
      titulo, 
      src, 
      key, 
      keyid
    });
    await nuevoVideo.save();
    res.status(201).json({ message: 'Video creado exitosamente', video: nuevoVideo });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete('/api/delete-all', async (req, res) => {
  try {
    // Borrar todos los documentos en la colección de videos
    await Video.deleteMany({});

    res.json({ message: 'Todos los videos han sido borrados exitosamente' });
  } catch (error) {
    console.error('Error al borrar los videos:', error);
    res.status(500).json({ error: error.message });
  }
});
app.post('/api/populate', async (req, res) => {
  try {
    // Array de videos de ejemplo
    const videosEjemplo = [
      { titulo: 'Video Demo 1', src: 'url1', key: 'clave1', keyid: 'keyid1' },
      { titulo: 'Video Demo 2', src: 'url2', key: 'clave2', keyid: 'keyid2' },
      // ... agregar 3 videos más
    ];

    // Insertar los videos en la base de datos
    await Video.insertMany(videosEjemplo);

    res.json({ message: 'Base de datos poblada con videos de ejemplo' });
  } catch (error) {
    console.error('Error al poblar la base de datos:', error);
    res.status(500).json({ error: error.message });
  }
});

const httpsPort = 443;


httpsServer.listen(httpsPort, () => {
  console.log(`Servidor HTTPS en https://localhost:${httpsPort}`);
});

