import { useEffect, useState } from 'react';
import './CharacterSelectionPage.css';
import { PXEFactory } from '../../factories/PXEFactory';
import { AztecAddress } from '@aztec/aztec.js';
import { useNavigate } from 'react-router-dom'; // Para navegar entre páginas

const CharacterSelectionPage = () => {
  const [pxeConnected, setPxeConnected] = useState(false);
  const [accounts, setAccounts] = useState<AztecAddress[]>([]);
  const [selectedCharacter, setSelectedCharacter] = useState<number | null>(null); // Estado para el personaje seleccionado
  const [error, setError] = useState<string>('');
  const navigate = useNavigate(); // Hook para cambiar de pantalla

  useEffect(() => {
    const connectToPXE = async () => {
      try {
        const pxe = await PXEFactory.getPXEInstance();

        const { l1ChainId } = await pxe.getNodeInfo();
        console.log(`Connected to chain ${l1ChainId}`);
        setPxeConnected(true);

        const userAccounts = await pxe.getRegisteredAccounts();
        setAccounts(userAccounts.map((account) => account.address));
      } catch (err) {
        if (err instanceof Error) {
          console.error(`Error connecting to PXE: ${err.message}`);
        } else {
          console.error('Error connecting to PXE:', err);
        }
        setError('Failed to connect to PXE');
      }
    };

    connectToPXE();
  }, []);

  const handleCharacterSelect = (index: number) => {
    setSelectedCharacter(index);
  };

  const handlePlay = () => {
    if (selectedCharacter !== null) {
      navigate('/game', { state: { selectedCharacter } }); // Navega a la pantalla del juego y pasa el personaje seleccionado
    }
  };

  return (
    <div style={{ textAlign: 'center', padding: '2rem' }}>
      <h1>Freedom Race</h1>
      <p>Status: {pxeConnected ? 'Connected to PXE' : error || 'Not connected to PXE'}</p>
      <div style={{ marginTop: '1rem' }}>
        {accounts.length > 0 ? (
          accounts.map((account, index) => (
            <button
              key={index}
              style={{
                padding: '0.5rem 1rem',
                margin: '0.5rem',
                border: selectedCharacter === index ? '2px solid green' : '1px solid gray',
                borderRadius: '5px',
                cursor: 'pointer',
              }}
              onClick={() => handleCharacterSelect(index)}
            >
              {`Account ${index + 1}: ${account.toString().slice(0, 5)}...${account.toString().slice(-4)}`}
            </button>
          ))
        ) : (
          <p>No accounts loaded</p>
        )}
      </div>
      <button
        style={{
          padding: '0.5rem 1rem',
          marginTop: '1rem',
          backgroundColor: selectedCharacter !== null ? 'blue' : 'gray',
          color: 'white',
          border: 'none',
          borderRadius: '5px',
          cursor: selectedCharacter !== null ? 'pointer' : 'not-allowed',
        }}
        onClick={handlePlay}
        disabled={selectedCharacter === null}
      >
        Jugar
      </button>
    </div>
  );
};

export default CharacterSelectionPage;
