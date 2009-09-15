#include "game.h"

Game::Game()
{
	balls.resize(1);
}

Game::~Game()
{
}

void Game::init_game()
{
	level = 1;
	lives = 5;

	game_field.do_new_random_level(1);
	restart_level();
}

void Game::restart_level()
{
	//This should actually be creating the /same/ level - but we will deal with this later
	game_field.do_new_random_level(level);

	//Now we continue because the level was just recreated
	continue_level();
}

void Game::continue_level()
{
	int i;
	for (i = 0; i < balls.size(); ++i)
	{
		balls.at(i).init(); // init the ball
		balls.at(i).sticky_time = BPS_OF_TIMER_MANAGER * 3; // 3 secs before launch of ball =)
	}

      paddle.init(); // init the mygame.paddle
      paddle.getMouse();

	Brick::resetAll();

}

int Game::lost_life()
{
	if (! flag_cheat )
	{
		--lives;
	}
	else
	{
		std::cout << "We are cheating..." << std::endl;
	}
	std::cout << " " << lives << " at level " << level <<std::endl;
	if (lives <= 0)
	{
		show_msg_center("Are you for real!");
		controls::waitUntilEvent();
		return GAME_UDP_LOST_GAME;
		// we need to have a better method of restarting game vs continuing level
	}
	else
	{
		show_msg_center("You lost!!");
		//textout_ex( screen, font, "You lost!!", SCREEN_H / 2, SCREEN_W / 2, makecol( 255, 0, 0), makecol( 0, 0, 0));
		controls::waitUntilEvent();
	}
	return KERNEL_UDP_OK;
}


void Game::next_level()
{
	++level;
}

void Game::prev_level()
{
	level = std::max(level - 1, 1);
}

void Game::update()
{
}

void Game::render(BITMAP *double_buffer)
{
	// first, everything gets drawed to the double buffer bitmap
	game_field.render(double_buffer); // render the game field (the bricks)
	paddle.render(double_buffer); // render the mygame.paddle
	int i;
	for (i = 0; i < balls.size(); ++i)
	{
		balls.at(i).render(double_buffer); // render the ball
	}
}
