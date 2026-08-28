# Document Desk

Document Desk is a local web app for asking questions about your PDF files. It extracts each page, indexes the text in a FAISS vector store, and sends the most relevant passages to an OpenAI model. Answers include the source document and page so you can check them.

The API is built with FastAPI. A small HTML, CSS, and JavaScript client is included, so there is no separate frontend build step.

## Features

- Upload and remove PDF files from the document library.
- Extract text page by page with pypdf.
- Split long pages into overlapping chunks.
- Search the chunks with OpenAI embeddings and FAISS.
- Ask follow-up questions in a saved conversation.
- Stream answers over Server-Sent Events, with page citations.
- Store document metadata and conversations in SQLite.
- Run the same service locally or in a container.

## How a question is answered

1. A PDF is saved under `data/uploads/` and its text is extracted.
2. The text is split into chunks and embedded.
3. FAISS stores the embeddings under `data/vector_store/`.
4. For each question, the closest chunks are retrieved.
5. The chat service sends those chunks and the conversation history to the configured OpenAI model.
6. The response is returned with the document and page for each citation.

## Project layout

```text
document-desk/
+-- document_desk/
|   +-- api/             FastAPI routes and dependency wiring
|   +-- core/            exceptions and shared prompts
|   +-- domain/          domain models and API schemas
|   +-- infrastructure/  SQLite and repository code
|   +-- services/        PDF, chunking, retrieval, and chat services
|   +-- static/          browser client
+-- data/
|   +-- uploads/         uploaded PDFs (kept out of git)
|   +-- vector_store/    persisted FAISS index (kept out of git)
|   +-- examples/        sample PDF for a first run
+-- tests/
+-- .env.example
+-- requirements.txt
+-- GETTING_STARTED.md
```

## Requirements

- Python 3.12 or newer
- An OpenAI API key for embeddings and chat
- A system package that can build `faiss-cpu` if a prebuilt wheel is not available

## Install

```bash
git clone https://github.com/shreyashree18/document-desk.git
cd document-desk

python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Copy the environment template and set your key:

```bash
cp .env.example .env
# edit .env and set OPENAI_API_KEY
```

The defaults use `data/` for the database, uploads, and FAISS files. Set `DATA_DIR`, `UPLOAD_DIR`, `VECTOR_STORE_DIR`, or `DATABASE_URL` in `.env` if you want a different location.

## Run the app

```bash
uvicorn document_desk.main:app --reload
```

Then open [http://localhost:8000](http://localhost:8000). The API documentation is available at [http://localhost:8000/api/docs](http://localhost:8000/api/docs).

On Windows, `start_document_desk.bat` starts the same server. On macOS, run `start_document_desk.command`.

## Main endpoints

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/api/health` | Check service status |
| GET | `/api/documents` | List uploaded documents |
| POST | `/api/documents` | Upload a PDF |
| DELETE | `/api/documents/{id}` | Remove a document |
| POST | `/api/chat` | Ask a question |
| POST | `/api/chat/stream` | Stream an answer |
| GET | `/api/docs` | OpenAPI documentation |

The exact request and response schemas are shown in the Swagger page.

## Tests and checks

Install the development tools and run the suite:

```bash
pip install -r requirements-dev.txt
ruff check document_desk tests
pytest
```

Tests that would make real embedding requests are skipped unless a real `OPENAI_API_KEY` is provided.

## Configuration notes

- `OPENAI_CHAT_MODEL` selects the chat model; the default is `gpt-4.1-mini`.
- `OPENAI_EMBEDDING_MODEL` selects the embedding model; the default is `text-embedding-3-small`.
- `MAX_UPLOAD_MB` limits uploaded file size.
- `CORS_ORIGINS` accepts a comma-separated list. The default `*` is intended for local development.
- Uploaded files, the FAISS index, the SQLite database, and logs are ignored by git.

For a slower, step-by-step setup guide, see [GETTING_STARTED.md](GETTING_STARTED.md).

## License

Document Desk is released under the MIT License.
