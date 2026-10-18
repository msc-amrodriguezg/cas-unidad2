const express = require('express');
const mysql = require('mysql2/promise');
const os = require('os');

const app = express();
app.use(express.urlencoded({ extended: false }));
app.use(express.static('public'));

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'mysql-db',
  user: 'root',
  password: process.env.DB_PASSWORD,
  database: 'biblioteca',
  connectionLimit: 5,
  dateStrings: true
});

const esc = s => String(s ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const h = fn => (req, res) => fn(req, res).catch(e => res.status(500).send('Error: ' + esc(e.message)));

const page = (titulo, cuerpo) => `<!doctype html><html lang="es"><meta charset="utf-8"><title>${titulo}</title>
<body style="font-family:sans-serif;max-width:900px;margin:2rem auto">
<img src="/logo.png" height="60" onerror="this.style.display='none'">
<h1>${titulo}</h1>
<nav><a href="/">Registrar libro</a> | <a href="/libros">Ver libros guardados en la BD</a></nav><hr>
${cuerpo}<hr><small>Servido desde el contenedor: <b>${os.hostname()}</b></small></body></html>`;

app.get('/', h(async (req, res) => {
  const [autores] = await pool.query('SELECT id, nombre FROM autores ORDER BY nombre');
  const opciones = autores.map(a => `<option value="${a.id}">${esc(a.nombre)}</option>`).join('');
  res.send(page('Registrar libro', `
  <form method="POST" action="/guardar">
    <p>Autor: <select name="autor_id">${opciones}</select></p>
    <p>Título: <input name="titulo" required></p>
    <p>ISBN (13): <input name="isbn" minlength="13" maxlength="13" required></p>
    <p>Fecha publicación: <input type="date" name="fecha_publicacion" required></p>
    <p>Precio: <input type="number" step="0.01" name="precio" required></p>
    <p><label><input type="checkbox" name="disponible" checked> Disponible</label></p>
    <button>Guardar</button>
  </form>`));
}));

app.post('/guardar', h(async (req, res) => {
  const { autor_id, titulo, isbn, fecha_publicacion, precio, disponible } = req.body;
  await pool.query(
    'INSERT INTO libros (autor_id,titulo,isbn,fecha_publicacion,disponible,precio) VALUES (?,?,?,?,?,?)',
    [autor_id, titulo, isbn, fecha_publicacion, disponible ? 1 : 0, precio]);
  res.redirect('/libros');
}));

app.get('/libros', h(async (req, res) => {
  const [filas] = await pool.query(
    `SELECT l.id, l.titulo, a.nombre AS autor, l.isbn, l.fecha_publicacion, l.disponible, l.precio
     FROM libros l JOIN autores a ON a.id = l.autor_id ORDER BY l.id`);
  const trs = filas.map(f => `<tr><td>${f.id}</td><td>${esc(f.titulo)}</td><td>${esc(f.autor)}</td><td>${esc(f.isbn)}</td><td>${f.fecha_publicacion}</td><td>${f.disponible ? 'Sí' : 'No'}</td><td>${f.precio}</td></tr>`).join('');
  res.send(page(`Libros en la base de datos (${filas.length})`,
    `<table border="1" cellpadding="6"><tr><th>ID</th><th>Título</th><th>Autor</th><th>ISBN</th><th>Fecha</th><th>Disp.</th><th>Precio</th></tr>${trs}</table>`));
}));

app.listen(3000, () => console.log('Servidor listo en el puerto 3000'));