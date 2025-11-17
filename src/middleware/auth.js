import fs from "fs";
import path from "path";
import logger from "../utils/logger.js";

let allowedTokens = new Set();
let tokensFilePath = null;
let lastModifiedTime = null;

/**
 * Inizializza il middleware di autenticazione caricando i token dal file
 * @param {string} filePath - Percorso del file contenente i token autorizzati
 */
export function initializeAuth(filePath) {
  if (!filePath) {
    logger.log("[AUTH] No token file specified - authentication disabled");
    return;
  }

  tokensFilePath = path.resolve(filePath);
  
  if (!fs.existsSync(tokensFilePath)) {
    logger.warn(`[AUTH] Token file not found: ${tokensFilePath} - authentication disabled`);
    tokensFilePath = null;
    return;
  }

  loadTokens();
  logger.log(`[AUTH] Authentication enabled with ${allowedTokens.size} token(s)`);
}

/**
 * Carica i token dal file (supporta hot-reload)
 */
function loadTokens() {
  try {
    const stats = fs.statSync(tokensFilePath);
    const currentModifiedTime = stats.mtimeMs;

    // Ricarica solo se il file è stato modificato
    if (lastModifiedTime !== null && lastModifiedTime === currentModifiedTime) {
      return;
    }

    const content = fs.readFileSync(tokensFilePath, "utf-8");
    const tokens = content
      .split("\n")
      .map((line) => line.trim())
      .filter((line) => line.length > 0 && !line.startsWith("#")); // Ignora righe vuote e commenti

    allowedTokens = new Set(tokens);
    lastModifiedTime = currentModifiedTime;

    logger.log(`[AUTH] Loaded ${allowedTokens.size} token(s) from ${tokensFilePath}`);
  } catch (error) {
    logger.error(`[AUTH] Error loading tokens: ${error.message}`);
    allowedTokens = new Set();
  }
}

/**
 * Middleware Express per verificare il bearer token
 */
export function authenticateProxy(req, res, next) {
  // Se non c'è un file di token configurato, passa oltre
  if (!tokensFilePath) {
    return next();
  }

  // Ricarica i token se il file è stato modificato (hot-reload)
  loadTokens();

  // Se non ci sono token configurati, nega l'accesso
  if (allowedTokens.size === 0) {
    logger.warn("[AUTH] No tokens configured - denying access");
    return res.status(503).json({ 
      error: "Service Unavailable", 
      message: "Authentication is enabled but no tokens are configured" 
    });
  }

  const authHeader = req.headers["authorization"];

  if (!authHeader) {
    logger.warn("[AUTH] Missing Authorization header", {
      ip: req.ip,
      path: req.path,
    });
    return res.status(401).json({ 
      error: "Unauthorized", 
      message: "Missing Authorization header" 
    });
  }

  // Estrae il token dall'header "Bearer <token>"
  const token = authHeader.startsWith("Bearer ")
    ? authHeader.substring(7)
    : authHeader;

  if (!allowedTokens.has(token)) {
    logger.warn("[AUTH] Invalid token", {
      ip: req.ip,
      path: req.path,
      tokenPrefix: token.substring(0, 8) + "...",
    });
    return res.status(403).json({ 
      error: "Forbidden", 
      message: "Invalid authentication token" 
    });
  }

  // Token valido - procedi
  logger.debug("[AUTH] Token validated successfully");
  next();
}
