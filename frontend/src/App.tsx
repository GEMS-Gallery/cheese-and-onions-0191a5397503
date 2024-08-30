import React, { useState, useEffect } from 'react';
import { Container, Typography, Button, Grid, Card, CardContent, CardActions, CircularProgress } from '@mui/material';
import { ThumbUp, ThumbDown } from '@mui/icons-material';
import { useForm } from 'react-hook-form';
import Modal from 'react-modal';
import { backend } from 'declarations/backend';

type Recipe = {
  id: bigint;
  title: string;
  ingredients: string[];
  instructions: string;
  upvotes: bigint;
  downvotes: bigint;
};

const App: React.FC = () => {
  const [recipes, setRecipes] = useState<Recipe[]>([]);
  const [loading, setLoading] = useState(true);
  const [modalIsOpen, setModalIsOpen] = useState(false);
  const [selectedRecipe, setSelectedRecipe] = useState<Recipe | null>(null);
  const { register, handleSubmit, reset } = useForm();

  useEffect(() => {
    fetchRecipes();
  }, []);

  const fetchRecipes = async () => {
    try {
      const fetchedRecipes = await backend.getAllRecipes();
      setRecipes(fetchedRecipes);
      setLoading(false);
    } catch (error) {
      console.error('Error fetching recipes:', error);
      setLoading(false);
    }
  };

  const openModal = (recipe: Recipe) => {
    setSelectedRecipe(recipe);
    setModalIsOpen(true);
  };

  const closeModal = () => {
    setSelectedRecipe(null);
    setModalIsOpen(false);
  };

  const onSubmit = async (data: any) => {
    setLoading(true);
    try {
      await backend.addRecipe(data.title, data.ingredients.split(','), data.instructions);
      reset();
      await fetchRecipes();
    } catch (error) {
      console.error('Error adding recipe:', error);
    }
    setLoading(false);
  };

  const handleRating = async (id: bigint, isUpvote: boolean) => {
    try {
      await backend.updateRating(id, isUpvote);
      await fetchRecipes();
    } catch (error) {
      console.error('Error updating rating:', error);
    }
  };

  return (
    <Container maxWidth="lg" className="py-8">
      <Typography variant="h2" component="h1" gutterBottom className="text-center text-4xl font-bold mb-8">
        Cheese & Onion Recipe Book
      </Typography>
      <Button variant="contained" color="primary" onClick={() => setModalIsOpen(true)} className="mb-8">
        Add New Recipe
      </Button>
      {loading ? (
        <CircularProgress />
      ) : (
        <Grid container spacing={4}>
          {recipes.map((recipe) => (
            <Grid item xs={12} sm={6} md={4} key={recipe.id.toString()}>
              <Card>
                <CardContent>
                  <Typography variant="h5" component="h2">
                    {recipe.title}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Ingredients: {recipe.ingredients.join(', ')}
                  </Typography>
                </CardContent>
                <CardActions>
                  <Button size="small" onClick={() => openModal(recipe)}>View Details</Button>
                  <Button size="small" onClick={() => handleRating(recipe.id, true)}><ThumbUp /> {recipe.upvotes.toString()}</Button>
                  <Button size="small" onClick={() => handleRating(recipe.id, false)}><ThumbDown /> {recipe.downvotes.toString()}</Button>
                </CardActions>
              </Card>
            </Grid>
          ))}
        </Grid>
      )}
      <Modal
        isOpen={modalIsOpen}
        onRequestClose={closeModal}
        contentLabel="Recipe Modal"
        className="modal"
        overlayClassName="overlay"
      >
        {selectedRecipe ? (
          <div>
            <h2>{selectedRecipe.title}</h2>
            <h3>Ingredients:</h3>
            <ul>
              {selectedRecipe.ingredients.map((ingredient, index) => (
                <li key={index}>{ingredient}</li>
              ))}
            </ul>
            <h3>Instructions:</h3>
            <p>{selectedRecipe.instructions}</p>
            <Button onClick={closeModal}>Close</Button>
          </div>
        ) : (
          <form onSubmit={handleSubmit(onSubmit)}>
            <h2>Add New Recipe</h2>
            <input {...register('title')} placeholder="Title" required />
            <input {...register('ingredients')} placeholder="Ingredients (comma-separated)" required />
            <textarea {...register('instructions')} placeholder="Instructions" required />
            <Button type="submit">Add Recipe</Button>
            <Button onClick={closeModal}>Cancel</Button>
          </form>
        )}
      </Modal>
    </Container>
  );
};

export default App;
