import { BrowserRouter, Route, Routes } from 'react-router-dom'
import MainPage from './pages/MainPage'
import SocketContextProvider from './contexts/SocketContextProvider'
import ControlPage from './pages/ControlPage'

function App() {

  return (
    <>
    <SocketContextProvider>
      <BrowserRouter>
        <Routes>
        <Route path="/" element={<MainPage />} />
        <Route path="/controls" element={<ControlPage />} />
        </Routes>
      </BrowserRouter>
    </SocketContextProvider>
    </>
  )
}

export default App
