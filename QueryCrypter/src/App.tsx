import '../public/scss/App.scss'
import { AiFillFolderOpen } from 'react-icons/ai'
import { VscNewFile } from 'react-icons/vsc'
import { BiSolidSave } from 'react-icons/bi'
import { BiSolidReport } from 'react-icons/bi'
import { FaDeleteLeft } from 'react-icons/fa6'
import { FaPlay } from 'react-icons/fa'
import CodeMirror from '@uiw/react-codemirror';
import { abyss } from '@uiw/codemirror-theme-abyss'
function App() {

  return (
    <section className='container'>
      {/* botones para nuevo, abrir, guardar y eliminar pestaña */}
      <div className='docs'>
        <button className='buttons'><VscNewFile /> Nuevo archivo</button>
        <button className='buttons'><BiSolidSave /> Guardar</button>
        <button className='buttons'><FaDeleteLeft /> Eliminar pestaña</button>
        <button className='buttons pe'><label htmlFor="inp" id='lb'><AiFillFolderOpen /> Abrir archivo</label> <input id="inp" type="file" /></button>
      </div>
      {/* boton de reportes */}
      <div className='docs'>
        <button className='buttons'><BiSolidReport /> Reportes</button>
      </div>
      {/* pestañas de archivos */}
      <div className='docs'>

        <button className='buttons files'>archivo1</button>
      </div>
      {/* boton de ejecutar */}
      <div>
        <button className="buttons"><FaPlay /> Ejecutar</button>
      </div>
      <div className='editor'>
        <CodeMirror
          className='code'
          width='100%'
          height='100%'
          theme={abyss}
        />
      </div>
      <textarea id="terminal" disabled ></textarea>

    </section>
  )
}

export default App
