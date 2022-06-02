#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "snake_utils.h"
#include "state.h"

/* Helper function definitions */
static char get_board_at(game_state_t* state, int x, int y);
static void set_board_at(game_state_t* state, int x, int y, char ch);
static bool is_tail(char c);
static bool is_snake(char c);
static char body_to_tail(char c);
static int incr_x(char c);
static int incr_y(char c);
static void find_head(game_state_t* state, int snum);
static char next_square(game_state_t* state, int snum);
static void update_tail(game_state_t* state, int snum);
static void update_head(game_state_t* state, int snum);

/* Helper function to get a character from the board (already implemented for you). */
static char get_board_at(game_state_t* state, int x, int y) {
  return state->board[y][x];
}

/* Helper function to set a character on the board (already implemented for you). */
static void set_board_at(game_state_t* state, int x, int y, char ch) {
  state->board[y][x] = ch;
}

/* Task 1 */
game_state_t* create_default_state() {
  // TODO: Implement this function.
  game_state_t *default_game = (game_state_t *) malloc(sizeof(game_state_t));
  // Sanity check
  if (default_game == NULL) {
    printf("Error! Out of memory.");
  }
  default_game -> x_size = 14;
  default_game -> y_size = 10;
  unsigned int width = default_game -> x_size;
  unsigned int height = default_game -> y_size;
  default_game -> board = (char **) malloc (sizeof(char *) * height);
  // Sanity check
  if (default_game -> board == NULL) {
    printf("Error! Out of memory.");
  }
  for (int i = 0; i < height; ++i)
  {
    default_game -> board[i] = (char *) malloc(sizeof(char) * width);
    for (int j = 0; j < width; ++j) {
      if (i == 0 || i == height - 1 || j == 0 || j == width - 1)
      {
        default_game -> board[i][j] = '#';
      }
      else {
        default_game -> board[i][j] = ' ';
      }
    }
  }
  default_game -> num_snakes = 1;
  set_board_at(default_game, 8, 5, '*');
  set_board_at(default_game, 4, 4, 'd');
  set_board_at(default_game, 5, 4, '>');
  default_game -> snakes = (snake_t *) malloc(sizeof(snake_t) * default_game -> num_snakes);
  default_game -> snakes -> tail_x = 4;
  default_game -> snakes -> tail_y = 4;
  default_game -> snakes -> head_x = 5;
  default_game -> snakes -> head_y = 4;
  default_game -> snakes -> live = true;
  return default_game;
}

/* Task 2 */
void free_state(game_state_t* state) {
  // TODO: Implement this function.
  free(state -> snakes);
  for (int i = 0; i < state -> y_size; ++i) {
    free(state -> board[i]);
  }
  free(state -> board);
  free(state);
  return;
}

/* Task 3 */
void print_board(game_state_t* state, FILE* fp) {
  // TODO: Implement this function.
  for (int y = 0; y < state -> y_size; ++y) {
    for (int x = 0; x < state -> x_size; ++x) {
      fprintf(fp, "%c", state -> board[y][x]);
    }
    fprintf(fp, "\n");
  }
  return;
}

/* Saves the current state into filename (already implemented for you). */
void save_board(game_state_t* state, char* filename) {
  FILE* f = fopen(filename, "w");
  print_board(state, f);
  fclose(f);
}

/* Task 4.1 */
static bool is_tail(char c) {
  // TODO: Implement this function.
  char *str = "wasd";
  while (*str != '\0') {
    if (c == *str)
      return true;
    str++;
  }
  return false;
}

static bool is_snake(char c) {
  // TODO: Implement this function.
  char *str = "wasd^<>vx";
  while (*str != '\0') {
    if (c == *str)
      return true;
    str++;
  }
  return false;
}

static char body_to_tail(char c) {
  // TODO: Implement this function.
  char convert = ' ';
  switch (c)
  {
  case '^':
    convert = 'w';
    break;
  
  case '<':
    convert = 'a';
    break;
  
  case '>':
    convert = 'd';
    break;
  
  case 'v':
    convert = 's';
    break;
  }
  return convert;
}

static int incr_x(char c) {
  // TODO: Implement this function.
  if (c == '>' || c == 'd')
    return 1;
  else if (c == '<' || c == 'a')
    return -1;
  else
    return 0;
}

static int incr_y(char c) {
  // TODO: Implement this function.
  if (c == 'v' || c == 's')
    return 1;
  else if (c == '^' || c == 'w')
    return -1;
  else
    return 0;
}

/* Task 4.2 */
static char next_square(game_state_t* state, int snum) {
  // TODO: Implement this function.
  unsigned int head_x = state -> snakes[snum].head_x;
  unsigned int head_y = state -> snakes[snum].head_y;
  char snake_head = state -> board[head_y][head_x];
  int dx = incr_x(snake_head);
  int dy = incr_y(snake_head);
  return state -> board[head_y + dy][head_x + dx];
}

/* Task 4.3 */
static void update_head(game_state_t* state, int snum) {
  // TODO: Implement this function.
  unsigned head_x = state -> snakes[snum].head_x;
  unsigned head_y = state -> snakes[snum].head_y;
  char snake_head = state -> board[head_y][head_x];
  int dx = incr_x(snake_head);
  int dy = incr_y(snake_head);
  state -> board[head_y + dy][head_x + dx] = snake_head;
  state -> snakes[snum].head_x = head_x + dx;
  state -> snakes[snum].head_y = head_y + dy;
  return;
}

/* Task 4.4 */
static void update_tail(game_state_t* state, int snum) {
  // TODO: Implement this function.
  unsigned int tail_x = state -> snakes[snum].tail_x;
  unsigned int tail_y = state -> snakes[snum].tail_y;
  char snake_tail = state -> board[tail_y][tail_x];
  state -> board[tail_y][tail_x] = ' ';
  int dx = incr_x(snake_tail);
  int dy = incr_y(snake_tail);
  state -> board[tail_y + dy][tail_x + dx] = body_to_tail(state -> board[tail_y + dy][tail_x + dx]);
  state -> snakes[snum].tail_x = tail_x + dx;
  state -> snakes[snum].tail_y = tail_y + dy;
  return;
}

/* Task 4.5 */
void update_state(game_state_t* state, int (*add_food)(game_state_t* state)) {
  // TODO: Implement this function.
  int num = state -> num_snakes;
  for (int i = 0; i < num; ++i) {
    char next_step = next_square(state, i);
    if (is_snake(next_step)) {
      state -> board[state -> snakes[i].head_y][state -> snakes[i].head_x] = 'x';
      state -> snakes[i].live = false;
    }
    switch (next_step)
    {
    case ' ':
      update_head(state, i);
      update_tail(state, i);
      break;
    case '#':
      state -> board[state -> snakes[i].head_y][state -> snakes[i].head_x] = 'x';
      state -> snakes[i].live = false;
      break;
    case '*':
      update_head(state, i);
      add_food(state);
      break;
    }
  }
  return;
}

/* Task 5 */
game_state_t* load_board(char* filename) {
  // TODO: Implement this function.
  game_state_t *game = (game_state_t *) malloc(sizeof(game_state_t));
  game -> board = (char **) malloc(sizeof(char *)*100);
  char buffer[100];
  game -> snakes = (snake_t *) malloc(sizeof(snake_t)*100);
  FILE *fp = fopen(filename, "r");
  // Sanity check
  if (!fp) {
    fprintf(stderr, "\nCannot open the file!\n");
    exit(1);
  }
  int length = 0;
  int i;
  for (i = 0; !feof(fp); ++i) {
    fgets(buffer, 1000, fp);
    length = strlen(buffer);
    game -> board[i] = (char *) malloc(sizeof(char) * length);
    for (int j = 0; j < length; ++j) {
      game -> board[i][j] = buffer[j];
    }
  }
  game -> x_size = length - 1;
  game -> y_size = i - 1;
  fclose(fp);
  return game;
}

/* Task 6.1 */
static void find_head(game_state_t* state, int snum) {
  // TODO: Implement this function.
  unsigned tail_x = state -> snakes[snum].tail_x;
  unsigned tail_y = state -> snakes[snum].tail_y;
  char tail = state -> board[tail_y][tail_x];
  int dx = 0;
  int dy = 0;
  char next_ch = tail;
  while (is_snake(next_ch)) {
    dx = incr_x(next_ch);
    dy = incr_y(next_ch);
    tail_x += dx;
    tail_y += dy;
    next_ch = state -> board[tail_y][tail_x];
  }
  state -> snakes[snum].head_x = tail_x - dx;
  state -> snakes[snum].head_y = tail_y - dy;
  return;
}

/* Task 6.2 */
game_state_t* initialize_snakes(game_state_t* state) {
  // TODO: Implement this function.
  unsigned width = state -> x_size;
  unsigned height = state -> y_size;
  unsigned num = 0;
  for (int y = 0; y < height; ++y) {
    for (int x = 0; x < width; ++x) {
      if (is_tail(state -> board[y][x])) {
        state -> snakes[num].tail_x = x;
        state -> snakes[num].tail_y = y;
        find_head(state, num);
        ++num;
      }
    }
  }
  state -> num_snakes = num;
  return state;
}
