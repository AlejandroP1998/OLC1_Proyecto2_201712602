import React ,{ useState } from 'react'
import CodeMirror from '@uiw/react-codemirror';
import { oneDarkTheme } from '@uiw/react-codemirror';
import { abyss } from '@uiw/codemirror-theme-abyss'; import { langs } from '@uiw/codemirror-extensions-langs';
import fileDownload from 'js-file-download';
import './App.css'


function App() {

  const [code, setCode] = useState('');
  const [out, setOut] = useState('');
  const [cst, setCst] = useState('');
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
        setCst(data.cst);
        setAst(data.ast);
      });
  }

  const handleGenerate = () => {
    console.log(cst);
    console.log();
    console.log(ast);

    fileDownload(cst, "cst.dot");
    fileDownload(ast, "ast.dot");

  }

  const handleFileUpload = (event) => {
    const uploadedFiles = event.target.files;
    const newFiles = Array.from(uploadedFiles);
    setFiles(newFiles);
  };

  const deleteW = () =>{
    files.splice(files.length-1,1);
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
        <button className='btn2' onClick={handleGenerate}> Reportes </button>
      </div>
    </div>
  )
}

export default App;