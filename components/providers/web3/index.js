import {
  createContext,
  useContext,
  useEffect,
  useState,
  useMemo
} from 'react'
import detectEthereumProvider from '@metamask/detect-provider'
import Web3 from 'web3'

const Web3Context = createContext(null)

export default function Web3Provider({ children }) {
  const [web3API, setWeb3API] = useState({
    provider: null,
    web3: null,
    contract: null,
    isLoading: true
  })

  useEffect(() => {
    const loadProvider = async () => {
      const provider = await detectEthereumProvider()

      if (provider) {
        const web3 = new Web3(provider)
        setWeb3API({
          provider,
          web3,
          contract: null,
          isLoading: false
        })
      } else {
        setWeb3API(initial => ({ ...initial, isLoading: false }))
        console.error('Please, install Metamask.')
      }
    }

    loadProvider()
  }, [])

  const _web3API = useMemo(() => ({
    ...web3API,
    connect: web3API.provider
      ? async () => {
        try {
          await web3API.provider.request({ method: 'eth_requestAccounts' })
        } catch {
          console.error('Cannot retreive account')
          window.location.reload()
        }
      }
      : () => console.error('Cannot connect to Metamask. Try to reload your browser.'),
  }), [web3API])

  return (
    <Web3Context.Provider value={_web3API}>
      {children}
    </Web3Context.Provider>
  )
}

export function useWeb3() {
  return useContext(Web3Context)
}

