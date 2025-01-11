import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import GamePage from './pages/GamePage/GamePage';
import CharacterSelectionPage from './pages/CharacterSelectionPage/CharacterSelectionPage';

const App = () => {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<CharacterSelectionPage />} />
        <Route path="/game" element={<GamePage />} />
      </Routes>
    </Router>
  );
};

export default App;
