import { useLocation } from 'react-router-dom';
import { useState } from 'react';
import './GamePage.css'; // Importa el archivo CSS

const STEPS = 10;
const INITIAL_POSITION = STEPS - 1;

const GamePage = () => {
  const location = useLocation();
  const { selectedCharacter } = location.state as { selectedCharacter: number }; // Recibe el personaje seleccionado
  const [positions, setPositions] = useState([INITIAL_POSITION, INITIAL_POSITION, INITIAL_POSITION]); // Posiciones iniciales de los jugadores

  const handleAction = (action: string, target: number) => {
    setPositions((prevPositions) => {
      const newPositions = [...prevPositions];
      if (action === 'advance') {
        newPositions[selectedCharacter] = Math.max(newPositions[selectedCharacter] - 1, 0);
      } else if (action === 'sabotage') {
        newPositions[target] = Math.min(newPositions[target] + 1, INITIAL_POSITION);
      }
      return newPositions;
    });
  };

  return (
    <div className="game-container">
      <h1>Freedom Race - Game</h1>
      <div className="tables-container">
        {['A', 'B', 'C'].map((player, index) => (
          <table key={index}>
            <tbody>
              {[...Array(10)].map((_, rowIndex) => (
                <tr key={rowIndex}>
                  <td className={positions[index] === rowIndex ? 'active' : ''}>
                    {positions[index] === rowIndex ? '●' : ''}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        ))}
      </div>
      <div className="buttons-container">
        <button onClick={() => handleAction('advance', selectedCharacter)}>Avanzar</button>
        <button onClick={() => handleAction('sabotage', 1)}>Sabotear a B</button>
        <button onClick={() => handleAction('sabotage', 2)}>Sabotear a C</button>
      </div>
    </div>
  );
};

export default GamePage;
