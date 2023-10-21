import React, { useState } from 'react'
import CodeMirror from '@uiw/react-codemirror';
import { oneDarkTheme } from '@uiw/react-codemirror';
import fileDownload from 'js-file-download';
import { langs } from '@uiw/codemirror-extensions-langs';
import './App.css'
import Viz from 'viz.js';
import { Module, render } from 'viz.js/full.render.js';

function App() {
  const [code, setCode] = useState('');
  const [out, setOut] = useState('');
  const [ast, setAst] = useState('');
  const [files, setFiles] = useState([]);

  const onChange = React.useCallback((value) => {
    setCode(value);
  }, []);

  const handleClick = () => {
    //console.log(code);
    fetch('http://localhost:3000/analyze', {
      headers: {
        'Content-Type': 'application/json'
      },
      method: 'POST',
      body: JSON.stringify({
        "code": code
      })
    }).then(res => res.json())
      .then(data => {
        setOut(data.console);
        setAst(data.ast);
      });
  }

  const handleGenerate = async () => {

    //fileDownload(ast, "ast.dot");
    // Crea una nueva instancia de Viz
    const viz = new Viz({ Module, render });//

    // Genera la imagen a partir del código DOT
    viz.renderString(ast)
      .then(result => {
        // 'result' contiene la imagen en formato SVG

        // Crea un elemento 'a' para descargar la imagen
        const link = document.createElement('a');
        link.href = `data:image/svg+xml;base64,${btoa(result)}`;
        link.download = 'ast.svg'; // Cambia el nombre del archivo si es necesario
        link.click();
      })
      .catch(error => {
        console.error('Error al generar la imagen:', error);
      });
  }



  const handleFileUpload = (event) => {
    const uploadedFiles = event.target.files;
    const newFiles = Array.from(uploadedFiles);
    setFiles(newFiles);
  };

  const deleteW = () => {
    files.splice(files.length - 1, 1);
  }

  const loadFileContent = (file) => {
    const reader = new FileReader();
    reader.onload = (e) => {
      const fileContent = e.target.result;
      setCode(fileContent);
    };
    reader.readAsText(file);
  };

  const createNewFile = () => {
    // Puedes proporcionar un nombre de archivo deseado aquí
    const fileName = `nuevo.txt`;
    downloadFile(fileName, code);
  };

  const saveToFile = () => {
    // Puedes proporcionar el nombre del archivo existente aquí
    const fileName = 'archivo_existente.txt';
    downloadFile(fileName, code);
  };

  const downloadFile = (fileName, content) => {
    const element = document.createElement('a');
    element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(content));
    element.setAttribute('download', fileName);
    element.style.display = 'none';
    document.body.appendChild(element);
    element.click();
    document.body.removeChild(element);
  };

  return (
    <div className='container'>
      <div className='buttons'>
        <input type="file" onChange={handleFileUpload} multiple />
        <button onClick={createNewFile}>Crear Nuevo Archivo</button>
        <button onClick={saveToFile}>Guardar en Archivo Existente</button>
        <button onClick={deleteW}>Eliminar pestaña</button>
      </div>

      <div className="file-buttons">
        {files.map((file, index) => (
          <button key={index} onClick={() => loadFileContent(file)}>
            {file.name}
          </button>
        ))}
      </div>

      <div className="editors">
        <CodeMirror
          className='cm1'
          width='100%'
          height='100%'
          value={code}
          onChange={onChange}
          extensions={[langs.sql()]}
        />

        <CodeMirror
          className='cm2'
          value={out}
          width='100%'
          height='100%'
          readOnly='true'
          theme={oneDarkTheme}
        />
      </div>
      <div className='button'>
        <button className='btn1' onClick={handleClick}> Ejecutar </button>
        <button className='btn2' onClick={handleGenerate}>Generar Gráfico</button>
        <div id="graph-container"></div>
      </div>
    </div>
  )
}

export default App;